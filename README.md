# dev-playground-techtrands

> 개발 기술 트렌드 실시간 분석 대시보드 - ELK 스택과 머신러닝을 활용한 기술 동향 추적 시스템

## 📋 프로젝트 개요

이 프로젝트는 **HackerNews의 게시글과 댓글 데이터를 실시간으로 수집하여 개발 기술 트렌드를 분석**하는 데이터 파이프라인입니다. 
ELK 스택과 자연어 처리 기술을 결합해 개발자들이 실제로 주목하는 기술들과 그에 대한 감정 변화를 추적할 수 있습니다.

### 주요 특징

- 📕 **Github 토픽 기반 사전 구축** - zero shot 분류기를 활용한 Github API api 최신 기술 키워드 수집/저장
- 🔄 **실시간 데이터 수집** - HackerNews API를 통한 자동화된 데이터 수집
- 🧠 **지능형 키워드 추출** - spaCy + TF-IDF 하이브리드 방식으로 정확한 기술 키워드 발견
- 💭 **감성분석** - VADER를 활용한 기술별 커뮤니티 반응 분석
- 📊 **실시간 대시보드** - Kibana를 통한 트렌드 시각화
- 🔍 **신기술 조기 발견** - 새롭게 떠오르는 기술과 프레임워크 자동 탐지

## 🛠 기술 스택

### Data Pipeline
- **Workflow Management**: Apache Airflow 3.0.2
- **Data Source**: HackerNews API
- **Language**: Python 3.11
- **Database**: PostgreSQL 17.5

### Natural Language Processing
- **Keyword Classification**: zero-shot-classfication
- **Keyword Extraction**: spaCy + scikit-learn TF-IDF (Hybrid)
- **Sentiment Analysis**: VADER Sentiment
- **Text Processing**: English-optimized pipeline

### ELK Stack
- **Search Engine**: Elasticsearch 8.18.3
- **Data Pipeline**: Logstash 8.18.3
- **Visualization**: Kibana 8.18.3
- **Real-time Indexing**: PostgreSQL → Elasticsearch sync

### Infrastructure
- **Containerization**: Docker & Docker Compose
- **Development Tools**: Makefile automation
- **Process Management**: Service-oriented architecture

## 🚀 시작하기

### 환경 요구사항
- Docker & Docker Compose
- 8GB+ RAM (권장: 16GB+)

### 설치 및 실행

1. **저장소 클론**
```bash
git clone <repository-url>
cd hackernews-tech-trends
```

2. **원클릭 환경 구축**
```bash
# 전체 시스템 초기 설정 (ELK + Airflow + PostgreSQL + 데이터 파이프라인)
make setup

# 개발 환경 시작
make dev
```

3. **대시보드 접속**
```
Kibana: http://localhost:8010
Airflow: http://localhost:8011
```

4. **데이터 수집 시작**
```bash
# DAG 활성화 및 데이터 수집 시작
make start-pipeline

# 로그 실시간 확인
make logs
```

## 💡 사용법

### 개발 환경 관리
```bash
# 전체 시스템 상태 확인
make status

# 특정 서비스 로그 확인
make logs-airflow    # Airflow 로그
make logs-elk        # ELK 스택 로그
make logs-postgres   # PostgreSQL 로그

# 서비스 재시작
make restart

# 전체 시스템 정리
make clean
```

### 데이터 파이프라인 관리
```bash
# DAG 수동 트리거
make trigger-dag

# 데이터베이스 초기화
make db-reset

# 키바나 대시보드 리셋
make kibana-reset

# 샘플 데이터 생성 (개발용)
make seed-data
```

## 🔍 데이터 플로우

```
HackerNews API
    ↓ (1시간마다)
Airflow DAG
    ├─ 데이터 수집 (requests)
    ├─ 키워드 추출 (spaCy + TF-IDF)
    ├─ 감성분석 (VADER)
    └─ PostgreSQL 저장
    ↓ (10분마다)
Logstash
    ↓ (실시간 동기화)
Elasticsearch
    ↓ (실시간 시각화)
Kibana 대시보드
```
