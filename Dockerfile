# =============================================================================
# HackerNews Tech Trends Analysis - Custom Airflow Image
# =============================================================================

FROM apache/airflow:2.11.0-python3.11

# 루트 사용자로 전환 (패키지 설치를 위해)
USER root

# 시스템 패키지 업데이트 및 필요한 패키지 설치
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        gcc \
        g++ \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# airflow 사용자로 다시 전환
USER airflow

# requirements.txt 복사 및 패키지 설치 (--force-reinstall 제거)
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# spaCy 영어 모델 다운로드
RUN python -m spacy download en_core_web_sm

# NLTK 데이터 다운로드 (필요한 것들만)
RUN python -c "import nltk; nltk.download('punkt'); nltk.download('stopwords'); nltk.download('vader_lexicon')"

# 작업 디렉토리 설정
WORKDIR /opt/airflow 