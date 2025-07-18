from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.models import Variable

from datetime import datetime, timedelta

# from transformers import pipeline

import requests
import json
import concurrent.futures
import html
import re
import time
import os

# DB 연결
from psycopg2 import connect
from psycopg2.extras import execute_values
from psycopg2.extensions import adapt
from psycopg2.extensions import register_adapter


# 최신 키워드 업데이트
def update_latest_keywords():
    # 파이프라인 생성
    # classifier = pipeline(
    #         "zero-shot-classification",
    #         model="facebook/bart-large-mnli"
    # )
    # 라벨 정의
    # labels = set_labels()
    # tech_labels = set_tech_labels()

    headers = set_headers()
    today = (datetime.now() - timedelta(days=1)).strftime('%Y-%m-%d')
    # today = '2023-01-01'
    print(f"🔍 최신 키워드 업데이트 시작: {today}")

    try:
        
        conn = set_conn()
        print("✅ DB 연결 성공!")
        
        cur = conn.cursor()
        print("📝 커서 생성 완료")

        success_list = []
        saved_count = 0

        # DB에서 가져와서 사용하는 방식(zero-shot 분류기 메모리 이슈 해결(서버용 pc에 탑재)되면 이걸로 전환)
        # all_tech_keywords = get_tech_keywords_from_db(cur)

        # 하드코딩 방식(이게 더 낫나..)
        all_tech_keywords = get_tech_keywords_from_predefined()
        
        for idx, keyword in enumerate(all_tech_keywords):
            # DB에서 가져와서 사용하는 방식
            # topic_keyword = keyword[0].lower()

            # 하드코딩 방식(이게 더 낫나..)
            topic_keyword = keyword.lower()

            # URL 로그 - 항상 출력
            api_url = f'https://api.github.com/search/repositories?q={topic_keyword if topic_keyword == "" else "topic:"+topic_keyword}+stars:>10000+pushed:>{today}'
            print(f"[{idx+1}/{len(all_tech_keywords)}] 🌐 API 호출: {api_url}")
            
            try:
                topic_keyword_response = requests.get(api_url, headers=headers)
                topic_keyword_data = topic_keyword_response.json()
                
                # API 응답 상태 로그
                print(f"[{idx+1}/{len(all_tech_keywords)}] 📡 API 응답 상태: {topic_keyword_response.status_code}")
                
                # 응답 데이터 요약 로그
                if 'total_count' in topic_keyword_data:
                    total_count = topic_keyword_data['total_count']
                    print(f"[{idx+1}/{len(all_tech_keywords)}] 📊 {topic_keyword} 검색 결과: {total_count}개")
                    
                    if total_count > 0:
                        print(f"[{idx+1}/{len(all_tech_keywords)}] 💾 {topic_keyword} 관련 토픽 저장 시작")
                        
                        topic_keyword_list = []
                        for repo in topic_keyword_data['items']:
                            if repo['name']:
                                repo_name = repo['name'].lower()
                                # 하이픈이 포함된 키워드는 제외(예: python-sdk)
                                if '-' in repo_name:
                                    continue
                                # ai 키워드 제외...너무 많이 나온다..
                                if 'ai' == repo_name:
                                    continue

                                topic_keyword_list.append(repo_name)
                        
                        # DB 저장
                        saved_count = 0
                        for new_keyword in topic_keyword_list:
                            cur = save_tech_keywords(cur, new_keyword)
                            
                            if cur.rowcount > 0:  # 실제로 삽입된 경우
                                saved_count += 1
                        
                        print(f"[{idx+1}/{len(all_tech_keywords)}] 💾 {topic_keyword} 완료: {saved_count}개 새로 저장")
                        success_list.extend(topic_keyword_list)
                    else:
                        print(f"[{idx+1}/{len(all_tech_keywords)}] ⚠️ {topic_keyword} 관련 토픽 없음")
                else:
                    # API 에러 응답
                    print(f"[{idx+1}/{len(all_tech_keywords)}] ❌ API 에러 응답: {topic_keyword_data}")
                    
            except Exception as api_error:
                print(f"[{idx+1}/{len(all_tech_keywords)}] ❌ API 호출 에러 ({topic_keyword}): {str(api_error)}")
            
            # Rate limit 준수
            print(f"[{idx+1}/{len(all_tech_keywords)}] ⏳ 2초 대기...")

            # 커밋
            conn.commit()
            print("✅ 트랜잭션 커밋 완료")
            time.sleep(2)

        print(f"\n📊 전체 요약:")
        print(f"  - 검색한 키워드: {len(all_tech_keywords)}개")
        print(f"  - 발견한 키워드: {len(success_list)}개")
        print(f"  - 키워드 목록: {success_list[:10]}{'...' if len(success_list) > 10 else ''}")
        print(f"  - 새로 저장된 키워드 수: {saved_count}")

            
    except Exception as e:
        print(f"❌ 메인 프로세스 오류: {str(e)}")
        raise e
        
    finally:
        if cur:
            cur.close()
            print("🔄 DB 커서 종료")
        if conn:
            conn.close() 
            print("🔌 DB 연결 종료")

dag = DAG(
    'DICTIONARY_SEARCH_FROM_GITHUB_DAG',
    description='키워드 사전구축을 위한 Github API 호출 DAG',
    schedule_interval='0 0 * * *', # 하루에 한번 실행
    start_date=datetime(2025, 7, 17),
    catchup=False
)


# Task 정의
# 1단계: 최신 키워드 업데이트
update_latest_keywords_task = PythonOperator(
    task_id='update_latest_keywords',
    python_callable=update_latest_keywords,
    dag=dag
)


# 라벨 설정
def set_labels():
    return [
        "software development and programming",
        "technology and engineering", 
        "developer tools and infrastructure",
        "political and social issues",
        "entertainment and media",
        "business and finance",
        "personal and lifestyle"
    ]

# 기술 라벨 설정
def set_tech_labels():
    return [
        "software development and programming",
        "technology and engineering", 
        "developer tools and infrastructure",
    ]

# 헤더 설정
def set_headers():
    return {
        'Authorization': f'Bearer {os.environ["GITHUB_TOKEN"]}',
        'Accept': 'application/vnd.github+json'
    }

# DB 연결
def set_conn():

    return connect(
        host=os.environ['HOST'],
        database=os.environ['DATABASE'],
        user=os.environ['USER'], 
        password=os.environ['PASSWORD'],
        port=os.environ['PORT']
    )

# DB에서 키워드 가져오기
def get_tech_keywords_from_db(cur):
    select_query = """
    SELECT keyword FROM tech_trends.tech_dictionary
    """
    cur.execute(select_query)
    all_tech_keywords = cur.fetchall()

    return all_tech_keywords

# 하드코딩 방식으로 키워드 가져오기
def get_tech_keywords_from_predefined():
    return ['framework', 'language']

# 키워드 저장
def save_tech_keywords(cur, new_keyword):
    insert_query = """
    INSERT INTO tech_trends.tech_dictionary (keyword, category) VALUES (%s, 'concept')
    ON CONFLICT (keyword) DO NOTHING
    """
    cur.execute(insert_query, (new_keyword,))
    return cur

# 기술 키워드 판별
# def check_tech_keyword(repo_name, classifier, tech_labels):
#     result = classifier(repo_name, tech_labels)
#     top_label = result['labels'][0]
#     top_score = result['scores'][0]
#     return top_label in tech_labels and top_score > 0.5