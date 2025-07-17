from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.models import Variable

from datetime import datetime, timedelta

import requests
import json
import concurrent.futures
import html
import re
import time
import os

# 자연어 처리 라이브러리 추가
import spacy
from sklearn.feature_extraction.text import TfidfVectorizer
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer
from bs4 import BeautifulSoup

# DB 연결
from psycopg2 import connect
from psycopg2.extras import execute_values
from psycopg2.extensions import adapt
from psycopg2.extensions import register_adapter

# spaCy 모델 및 VADER 감성분석기 초기화 (전역변수로 한번만 로드)
nlp = spacy.load("en_core_web_sm")  # pip install en_core_web_sm 필요
analyzer = SentimentIntensityAnalyzer()

# 기술 키워드 사전 (HackerNews에서 자주 언급되는 기술 용어들)
ALL_TECH_KEYWORDS = set()  # 모든 기술 키워드를 하나의 set으로 관리


"""

1. 모든 기술 키워드를 하나의 set으로 통합
2. 최근 게시글 목록 가져오기
3. 최근 게시글 목록 중 처리되지 않은 게시글 목록 추출
4. 처리되지 않은 게시글 목록 상세정보 수집 (XCom으로 전달)
5. 감성분석, 키워드 추출 (기술 키워드 우선)
6. 감성분석, 키워드 추출 결과 출력
7. 감성분석, 키워드 추출 결과를 데이터베이스에 저장
"""

    


# 텍스트 전처리 함수 (HTML 디코딩 및 정리)
def clean_text(text):
    """
    HTML 인코딩 문제 해결 및 텍스트 정리
    """
    if not text or text == 'None':
        return ""
    
    # HTML 엔티티 디코딩 (&quot; → ", &#x27; → ' 등)
    text = html.unescape(text)
    
    # HTML 태그 제거 (BeautifulSoup 사용)
    soup = BeautifulSoup(text, 'html.parser')
    text = soup.get_text()
    
    # 불필요한 특수문자 제거 (단, 하이픈과 언더스코어는 유지)
    text = re.sub(r'[^\w\s\-_]', ' ', text)
    
    # 연속된 공백 제거
    text = re.sub(r'\s+', ' ', text).strip()
    
    return text


# 모든 기술 키워드를 하나의 set으로 통합
def set_all_tech_keywords():
    try:
        conn = connect(
            host=os.environ['HOST'],
            database=os.environ['DATABASE'],
            user=os.environ['USER'], 
            password=os.environ['PASSWORD'],
            port=os.environ['PORT']
        )
        print("✅ DB 연결 성공!")
        
        cur = conn.cursor()
        print("📝 커서 생성 완료")
        
        select_query = """
        SELECT keyword FROM tech_trends.tech_dictionary
        """
        cur.execute(select_query)
        all_tech_keywords = cur.fetchall()
        for keyword in all_tech_keywords:
            ALL_TECH_KEYWORDS.add(keyword[0].lower())
        print(f"🔍 모든 기술 키워드 세팅 완료: {len(ALL_TECH_KEYWORDS)}개")
    except Exception as e:
        print(f"❌ 오류 발생: {str(e)}")
        raise e
    finally:
        if cur:
            cur.close()
            print("\n🔄 DB 커서 종료") 
            print(ALL_TECH_KEYWORDS) 


# 최근 게시글 목록 가져오기
def get_new_story_ids():
    # 저장된 게시글 목록 가져오기 (DAG Run 간 데이터 공유)
    try:
        processed_story_ids = json.loads(Variable.get("processed_story_ids", default_var="[]"))
        print("이전에 처리된 게시글:", len(processed_story_ids), "개")
    except:
        processed_story_ids = []
    
    # 다양한 스토리 목록 API 호출하여 ID 수집
    story_ids = set()
    
    # 각 API 엔드포인트 호출
    api_endpoints = [
        'topstories',    # 최고 인기 스토리
        'newstories',    # 최신 스토리
        'beststories',   # 베스트 스토리
        'askstories',    # Ask HN 스토리
        'showstories'    # Show HN 스토리
    ]
    
    for endpoint in api_endpoints:
        response = requests.get(f'https://hacker-news.firebaseio.com/v0/{endpoint}.json')
        story_ids.update(response.json())  # set에 중복없이 추가
    
    all_story_ids = list(story_ids)  # set을 list로 변환
    
    # 처리되지 않은 게시글만 찾기 (차집합 연산)
    new_story_ids = [story_id for story_id in all_story_ids if story_id not in processed_story_ids]
    print("새로 처리할 게시글:", len(new_story_ids), "개")
    
    return new_story_ids

# 게시글 상세 정보 가져오기 및 XCom에 저장
def get_story_detail(**context):
    # Xcom에서 처리할 게시글 ID 목록 가져오기
    new_story_ids = context['ti'].xcom_pull(task_ids='get_new_story_ids')
    stories_data = []  # XCom으로 전달할 데이터 리스트
    
    # 최대 10개 게시글만 처리 (테스트용 제한)
    for i in new_story_ids:
        # 개별 게시글 상세정보 API 호출
        response = requests.get(f'https://hacker-news.firebaseio.com/v0/item/{i}.json')
        story_data = response.json()
        
        # 삭제된 게시글 체크 (dead 플래그)
        isDead = story_data.get('dead', False)
        if not isDead:
            # 필요한 데이터만 추출
            title = story_data.get('title', 'None')
            text = story_data.get('text', 'None')  # 게시글 본문 (있는 경우만)
            url = story_data.get('url', '')
            score = story_data.get('score', 0)
            type = story_data.get('type')
            kids = story_data.get('kids', [])
            for kid in kids:
                kid_data = requests.get(f'https://hacker-news.firebaseio.com/v0/item/{kid}.json')
                kid_data = kid_data.json()
                if kid_data.get('type') == 'comment':
                    comment_id = kid_data.get('id')
                    comment_parent_title = title
                    comment_text = kid_data.get('text', 'None')
                    comment_url = None
                    comment_score = 0
                    comment_author = kid_data.get('by', 'Unknown')
                    comment_type = kid_data.get('type')
                    comment_parent_id = kid_data.get('parent')
                    comment_detail = {
                        'id': comment_id,
                        'title': comment_parent_title,
                        'text': comment_text,
                        'url': comment_url,
                        'score': comment_score,
                        'author': comment_author,
                        'type': comment_type,
                        'parent_id': comment_parent_id
                    }
                    stories_data.append(comment_detail)
                    print(f"{i}번 게시글 댓글 수집 완료: ID {comment_id} - {comment_parent_title[:50]}...")

            
            # 상세정보 구조체 생성
            story_detail = {
                'id': i,
                'title': title,
                'text': text,
                'url': url,
                'score': score,
                'author': story_data.get('by', 'Unknown'),
                'type': type,
                'parent_id': None
            }
            
            stories_data.append(story_detail)
            print(f"본문 수집 완료: ID {i} - {title[:50]}...")
    
    print(f"총 {len(stories_data)}개 게시글 상세정보 수집 완료")
    
    # XCom으로 다음 Task에 데이터 전달 (return 방식)
    return stories_data

# 기술 키워드 가중치 적용 함수
def apply_tech_weights(keywords_with_scores):
    """
    기술 키워드에 가중치를 적용하여 우선적으로 추출되도록 함
    """
    weighted_keywords = []
    
    for keyword, score in keywords_with_scores:
        # 기술 키워드인지 확인 (대소문자 무관)
        if keyword.lower() in ALL_TECH_KEYWORDS:
            # 기술 키워드는 3배 가중치 적용
            weighted_keywords.append((keyword, score * 3.0))
            print(f"🔧 기술 키워드 발견: {keyword} (가중치 적용)")
        else:
            weighted_keywords.append((keyword, score))
    
    # 점수 순으로 재정렬
    return sorted(weighted_keywords, key=lambda x: x[1], reverse=True)

# 키워드 추출 함수 (spaCy + TF-IDF 하이브리드 방식 + 기술 키워드 우선)
def extract_keywords(text):
    """
    spaCy와 TF-IDF를 조합한 키워드 추출 + 기술 키워드 우선 처리
    """
    # 텍스트 전처리 (HTML 디코딩 등)
    clean_text_data = clean_text(text)
    
    # spaCy로 텍스트 분석 (토큰화, 품사 태깅, 불용어 제거)
    doc = nlp(clean_text_data)
    keywords_spacy = []
    
    # 명사, 고유명사, 형용사만 키워드 후보로 추출
    for token in doc:
        if (token.pos_ in ['NOUN', 'PROPN', 'ADJ'] and  # 품사 필터링
            not token.is_stop and                        # 불용어 제거
            not token.is_punct and                       # 구두점 제거
            len(token.text) > 2 and                      # 너무 짧은 단어 제거
            not token.text.isdigit()):                   # 숫자만 있는 토큰 제거
            keywords_spacy.append(token.lemma_.lower())   # 원형으로 변환 후 소문자화
    
    # TF-IDF로 키워드 중요도 점수 계산
    if len(keywords_spacy) > 0:
        try:
            # TF-IDF 벡터화 (최대 15개 특성, 영어 불용어 제거)
            vectorizer = TfidfVectorizer(max_features=15, stop_words='english')
            tfidf_matrix = vectorizer.fit_transform([clean_text_data])
            feature_names = vectorizer.get_feature_names_out()
            tfidf_scores = tfidf_matrix.toarray()[0]
            
            # 모든 키워드와 점수 추출
            all_keywords = [(feature_names[i], tfidf_scores[i]) for i in range(len(feature_names))]
            
            # 기술 키워드 가중치 적용
            weighted_keywords = apply_tech_weights(all_keywords)
            
            # 상위 8개 키워드 선택
            top_keywords = weighted_keywords[:8]
            
        except Exception as e:
            print(f"TF-IDF 처리 중 오류: {e}")
            # TF-IDF 실패시 spaCy 키워드 상위 8개 사용
            spacy_keywords = [(kw, 0.5) for kw in list(set(keywords_spacy))[:8]]
            top_keywords = apply_tech_weights(spacy_keywords)
    else:
        top_keywords = []
    
    return top_keywords

# 감성분석 함수 (VADER 활용)
def analyze_sentiment(text):
    """
    VADER를 사용한 감성분석
    """
    # 텍스트 전처리
    clean_text_data = clean_text(text)
    
    # VADER로 감성 점수 계산
    sentiment_scores = analyzer.polarity_scores(clean_text_data)
    
    # compound 점수를 기준으로 감성 라벨 분류
    compound = sentiment_scores['compound']
    if compound >= 0.05:      # 긍정적
        sentiment_label = 'positive'
    elif compound <= -0.05:   # 부정적
        sentiment_label = 'negative'
    else:                     # 중립적
        sentiment_label = 'neutral'
    
    return {
        'label': sentiment_label,
        'compound': compound,
        'positive': sentiment_scores['pos'],
        'neutral': sentiment_scores['neu'],
        'negative': sentiment_scores['neg']
    }

# 감성분석 + 키워드 추출 통합 함수
def analyze_content(title, text):
    """
    게시글의 제목과 본문을 분석하여 키워드 추출 및 감성분석 수행
    """
    # 제목과 본문을 합쳐서 분석 (본문이 있으면 추가, 없으면 제목만)
    combined_text = title
    if text and text != 'None' and text.strip():
        combined_text = f"{title} {text}"
        print(f"📄 본문 포함 분석: 제목 + 본문 ({len(text)} 글자)")
    else:
        print(f"📄 제목만 분석: {title}")
    
    # 키워드 추출 실행 (기술 키워드 우선)
    keywords = extract_keywords(combined_text)
    
    # 감성분석 실행
    sentiment = analyze_sentiment(combined_text)
    
    # 결과 구조체 생성
    analysis_result = {
        'keywords': [kw[0] for kw in keywords],           # 키워드 목록
        'keyword_scores': dict(keywords),                 # 키워드별 중요도 점수
        'sentiment': sentiment,                           # 감성분석 결과
        'has_text': text and text != 'None' and text.strip()  # 본문 존재 여부
    }
    
    return analysis_result

# 감성분석 + 키워드 추출 메인 Task 함수
def process_sentiment_and_keywords(**context):
    """
    XCom에서 게시글 데이터를 받아와서 감성분석과 키워드 추출 수행
    기술 키워드가 하나도 없는 게시글은 분석에서 배제
    """
    # XCom에서 이전 Task의 데이터 가져오기
    stories_data = context['ti'].xcom_pull(task_ids='get_story_detail')
    
    # 데이터가 없는 경우 처리
    if not stories_data:
        print("분석할 게시글 데이터가 없습니다.")
        return
    
    print(f"🤖 감성분석 및 키워드 추출 시작: {len(stories_data)}개 게시글")
    print("🔍 기술 키워드가 포함된 게시글만 분석합니다.")
    print("=" * 80)
    
    # 기술 키워드 통계
    tech_keyword_count = 0
    total_keyword_count = 0
    analyzed_stories = 0  # 실제 분석된 게시글 수
    skipped_stories = 0   # 건너뛴 게시글 수

    tech_trends_data = []
    
    # 각 게시글에 대해 분석 수행
    for idx, story in enumerate(stories_data, 1):
        print(f"\n[{idx}/{len(stories_data)}] 게시글 예비 분석 중...")
        print(f"🆔 ID: {story['id']}")
        print(f"📰 제목: {story['title']}")
        
        # 먼저 키워드 추출하여 기술 키워드 존재 여부 확인
        combined_text = story['title']
        if story['text'] and story['text'] != 'None' and story['text'].strip():
            combined_text = f"{story['title']} {story['text']}"
        
        # 키워드 추출 (기술 키워드 우선)
        keywords = extract_keywords(combined_text)
        
        # 기술 키워드가 있는지 확인
        tech_keywords = []
        for kw, _ in keywords:
            if kw.lower() in ALL_TECH_KEYWORDS:
                tech_keywords.append(kw)
        
        # 기술 키워드가 하나도 없으면 건너뛰기
        if not tech_keywords:
            print(f"❌ 기술 키워드 없음 - 분석 건너뛰기")
            print(f"   추출된 키워드: {', '.join([kw[0] for kw in keywords[:3]])}...")
            skipped_stories += 1
            print("-" * 60)
            continue
        
        # 기술 키워드가 있는 경우에만 전체 분석 진행
        print(f"✅ 기술 키워드 발견 - 전체 분석 진행")
        print(f"👤 작성자: {story['author']}")
        print(f"⬆️ 점수: {story['score']}")
        
        # 감성분석 실행
        sentiment = analyze_sentiment(combined_text)
        
        # 분석 결과 구성
        analysis_result = {
            'keywords': [kw[0] for kw in keywords],
            'keyword_scores': dict(keywords),
            'sentiment': sentiment,
            'has_text': story['text'] and story['text'] != 'None' and story['text'].strip()
        }
        
        # 통계 업데이트
        tech_keyword_count += len(tech_keywords)
        total_keyword_count += len(analysis_result['keywords'])
        analyzed_stories += 1
        
        # 분석 결과 출력
        print(f"🔑 전체 키워드: {', '.join(analysis_result['keywords'])}")
        print(f"🔧 기술 키워드: {', '.join(tech_keywords)} ({len(tech_keywords)}개)")
        print(f"💭 감성: {analysis_result['sentiment']['label']} (점수: {analysis_result['sentiment']['compound']:.3f})")
        
        tech_trends_data.append({
            'id': story['id'],
            'item_type': story['type'],
            'text_content': story['text'] if story['text'] and story['text'] != 'None' and story['text'].strip() else story['title'],
            'sentiment_score': analysis_result['sentiment']['compound'],
            'sentiment_label': analysis_result['sentiment']['label'],
            'extracted_keywords': next((kw for kw, score in analysis_result['keyword_scores'].items() if kw.lower() in ALL_TECH_KEYWORDS), ''),
            'author': story['author'],
            'created_at': datetime.now(),
            'score': story['score'],
            'parent_id': story['parent_id'],
            'root_story_id': 0
        })

        # 키워드별 중요도 점수 출력 (상위 4개만)
        if analysis_result['keyword_scores']:
            top_keywords = list(analysis_result['keyword_scores'].items())[:4]
            keyword_str = ', '.join([f"{kw}({score:.2f})" for kw, score in top_keywords])
            print(f"📊 주요 키워드 점수: {keyword_str}")
        
        # 본문 포함 여부 표시
        if analysis_result['has_text']:
            print("📝 본문 데이터 포함됨")
            print(f"📄 본문 포함 분석: 제목 + 본문 ({len(story['text'])} 글자)")
        else:
            print(f"📄 제목만 분석: {story['title']}")
        
        print("-" * 60)
    
    # 최종 통계 출력
    tech_ratio = (tech_keyword_count / total_keyword_count * 100) if total_keyword_count > 0 else 0
    analyzed_ratio = (analyzed_stories / len(stories_data) * 100) if len(stories_data) > 0 else 0
    
    print(f"\n📈 분석 완료 통계:")
    print(f"   전체 게시글: {len(stories_data)}개")
    print(f"   분석된 게시글: {analyzed_stories}개 ({analyzed_ratio:.1f}%)")
    print(f"   건너뛴 게시글: {skipped_stories}개 (기술 키워드 없음)")
    print(f"   총 키워드: {total_keyword_count}개")
    print(f"   기술 키워드: {tech_keyword_count}개 ({tech_ratio:.1f}%)")
    print(f"   기술 키워드 밀도: {tech_keyword_count/analyzed_stories:.1f}개/게시글" if analyzed_stories > 0 else "   기술 키워드 밀도: 0개/게시글")
    print(f"\n🎯 결과: 기술 관련 게시글만 선별 분석하여 더 정확한 기술 트렌드 파악!")
    
    print(f"   기술 게시글 필터링 성공률: {analyzed_ratio:.1f}%")

    return tech_trends_data


def insert_tech_trends_data(**context):
    cur = None
    conn = None
    print("\n🗃️ DB 저장 작업 시작...")
    
    # XCom에서 분석 데이터 가져오기
    tech_trends_data = context['ti'].xcom_pull(task_ids='process_sentiment_and_keywords')
    if not tech_trends_data:
        all_story_ids = json.loads(Variable.get("processed_story_ids", default_var="[]"))
        new_story_ids = context['ti'].xcom_pull(task_ids='get_new_story_ids')
        all_story_ids.extend(new_story_ids)  # 필터링 여부와 관계없이 모든 ID 추가
        Variable.set("processed_story_ids", json.dumps(list(set(all_story_ids))))  # 중복 제거
        print(f"처리된 게시글 ID 목록: {all_story_ids}")
        print("분석 데이터가 없습니다.")
        return
    print(f"📥 XCom에서 {len(tech_trends_data)}개 게시글 데이터 로드 완료")
    
    print("\n🔌 PostgreSQL DB 연결 시도...")
    try:
        conn = connect(
            host=os.environ['HOST'],
            database=os.environ['DATABASE'],
            user=os.environ['USER'], 
            password=os.environ['PASSWORD'],
            port=os.environ['PORT']
        )
        print("✅ DB 연결 성공!")
        
        cur = conn.cursor()
        print("📝 커서 생성 완료")
        
        # SQL 쿼리 준비
        insert_query = """
        INSERT INTO tech_trends.tech_trends_items (
            id, 
            item_type, 
            text_content, 
            sentiment_score, 
            sentiment_label,
            extracted_keywords, 
            author, 
            created_at, 
            score, 
            parent_id, 
            root_story_id
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        
        print("\n💾 데이터 저장 시작...")
        print("=" * 60)
        
        # 데이터 삽입 실행
        # 딕셔너리를 튜플 리스트로 변환 (한 줄로)
        data_tuples = [
            (
                item['id'],
                item['item_type'], 
                item['text_content'],
                item['sentiment_score'],
                item['sentiment_label'],
                item['extracted_keywords'],
                item['author'],
                item['created_at'],
                item['score'],
                item['parent_id'],
                item['root_story_id']
            )
            for item in tech_trends_data
        ]

        # 데이터 삽입 실행
        cur.executemany(insert_query, data_tuples)
        print(f"✨ {len(tech_trends_data)}개 게시글 데이터 삽입 완료!")
        
        # 커밋
        conn.commit()
        print("✅ 트랜잭션 커밋 완료")
        
        # 저장된 데이터 요약 출력
        for idx, data in enumerate(tech_trends_data, 1):
            print(f"\n📎 게시글 {idx}/{len(tech_trends_data)}")
            print(f"   제목: {data['text_content'][:50]}...")
            print(f"   작성자: {data['author']}")
            print(f"   감성: {data['sentiment_label']} ({data['sentiment_score']:.2f})")
            
        # 모든 게시글 ID를 processed_story_ids에 추가
        try:
            all_story_ids = json.loads(Variable.get("processed_story_ids", default_var="[]"))
            new_story_ids = context['ti'].xcom_pull(task_ids='get_new_story_ids')
            all_story_ids.extend(new_story_ids)  # 필터링 여부와 관계없이 모든 ID 추가
            Variable.set("processed_story_ids", json.dumps(list(set(all_story_ids))))  # 중복 제거
            print("\n✅ processed_story_ids 업데이트 완료")
        except Exception as e:
            print(f"\n❌ processed_story_ids 업데이트 실패: {str(e)}")
            
    except Exception as e:
        print(f"❌ 오류 발생: {str(e)}")
        raise e
        
    finally:
        # 연결 종료
        if cur:
            cur.close()
            print("\n🔄 DB 커서 종료")
        if conn:
            conn.close() 
            print("🔌 DB 연결 종료")
    
    print("\n✅ DB 저장 작업 완료!")
    print("=" * 60)



default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2025, 7, 15),
    'retries': 0,
    'retry_delay': 0
}

dag = DAG(
    'HACKER_NEWS_TECH_ANALYSIS_DAG',
    default_args=default_args,
    description='Hacker News 기술 트렌드 감성분석 및 키워드 추출 DAG (기술 게시글 필터링)',
    schedule_interval='*/30 * * * *',  # 20분에 한번씩 실행
    catchup=False
)



# 1단계: 모든 기술 키워드 세팅
set_all_tech_keywords_task = PythonOperator(
    task_id='set_all_tech_keywords',
    python_callable=set_all_tech_keywords,
    dag=dag
)

# 2단계: 새로운 게시글 ID 수집
new_story_ids_task = PythonOperator(
    task_id='get_new_story_ids',
    python_callable=get_new_story_ids,
    dag=dag
)

# 3단계: 게시글 상세정보 수집
story_detail_task = PythonOperator(
    task_id='get_story_detail',
    python_callable=get_story_detail,
    dag=dag
)

# 4단계: 기술 게시글 필터링 및 분석
analysis_task = PythonOperator(
    task_id='process_sentiment_and_keywords',
    python_callable=process_sentiment_and_keywords,
    dag=dag
)

# 5단계: 데이터베이스에 저장
insert_tech_trends_data_task = PythonOperator(
    task_id='insert_tech_trends_data',
    python_callable=insert_tech_trends_data,
    dag=dag
)

# Task 실행 순서 정의 (1단계 → 2단계 → 3단계 → 4단계 → 5단계)
set_all_tech_keywords_task >> new_story_ids_task >> story_detail_task >> analysis_task >> insert_tech_trends_data_task