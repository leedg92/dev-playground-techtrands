# Makefile for HackerNews Tech Trends Analysis Project
# 프로젝트: 개발 기술 트렌드 실시간 분석 대시보드
# Apache Airflow 3.0.3 호환

# 변수 정의
COMPOSE_FILE = docker-compose.yaml
AIRFLOW_SERVICE = airflow-webserver  # Airflow 2.x Webserver
SCHEDULER_SERVICE = airflow-scheduler
WORKER_SERVICE = airflow-worker
DB_SERVICE = postgres
ELASTICSEARCH_SERVICE = elasticsearch
KIBANA_SERVICE = kibana
LOGSTASH_SERVICE = logstash
REDIS_SERVICE = redis

# 포트 설정
AIRFLOW_PORT = 8011  # Airflow 2.x Webserver
KIBANA_PORT = 8010
POSTGRES_PORT = 3316
ELASTICSEARCH_PORT = 9200

# 기본 타겟 (help 출력)
.DEFAULT_GOAL := help

# PHONY 타겟 선언
.PHONY: help setup build dev dev-build stop clean logs status shell restart
.PHONY: airflow-up airflow-down airflow-logs airflow-shell airflow-reset
.PHONY: elk-up elk-down elk-logs elk-status kibana-reset
.PHONY: db-up db-down db-logs db-shell db-reset
.PHONY: start-pipeline stop-pipeline trigger-dag
.PHONY: clean-all seed-data

# 도움말 출력
help:
	@echo "🚀 HackerNews Tech Trends Analysis - 개발 명령어 (Airflow 3.0.3)"
	@echo ""
	@echo "📦 설치 및 설정:"
	@echo "  make setup       - 전체 시스템 초기 설정 (ELK + Airflow + PostgreSQL)"
	@echo "  make build       - Docker 이미지 빌드"
	@echo "  make build-nc    - Docker 이미지 빌드 (캐시 없이)"
	@echo ""
	@echo "🔧 개발 환경:"
	@echo "  make dev         - 개발 환경 시작 (모든 서비스)"
	@echo "  make dev-build   - 빌드 후 개발 환경 시작"
	@echo "  make stop        - 모든 서비스 중지"
	@echo "  make restart     - 모든 서비스 재시작"
	@echo "  make status      - 컨테이너 상태 확인"
	@echo ""
	@echo "✈️  Airflow 3.0.3 관리:"
	@echo "  make airflow-up    - Airflow 서비스만 시작"
	@echo "  make airflow-down  - Airflow 서비스 중지"
	@echo "  make airflow-logs  - Airflow 로그 확인"
	@echo "  make airflow-shell - Airflow API 서버 컨테이너 접속"
	@echo "  make airflow-reset - Airflow 메타데이터 초기화"
	@echo ""
	@echo "📊 ELK Stack 관리:"
	@echo "  make elk-up        - ELK Stack만 시작"
	@echo "  make elk-down      - ELK Stack 중지"
	@echo "  make elk-logs      - ELK Stack 로그 확인"
	@echo "  make elk-status    - ELK Stack 상태 확인"
	@echo "  make kibana-reset  - Kibana 대시보드 리셋"
	@echo ""
	@echo "🗄️  데이터베이스 관리 (PostgreSQL 16):"
	@echo "  make db-up         - PostgreSQL 컨테이너만 시작"
	@echo "  make db-down       - PostgreSQL 컨테이너 중지"
	@echo "  make db-logs       - PostgreSQL 로그 확인"
	@echo "  make db-shell      - PostgreSQL 콘솔 접속"
	@echo "  make db-reset      - 데이터베이스 초기화"
	@echo ""
	@echo "🔄 데이터 파이프라인:"
	@echo "  make start-pipeline - DAG 활성화 및 데이터 수집 시작"
	@echo "  make stop-pipeline  - 데이터 파이프라인 중지"
	@echo "  make trigger-dag    - DAG 수동 트리거"
	@echo "  make seed-data      - 샘플 데이터 생성 (개발용)"
	@echo ""
	@echo "📋 모니터링:"
	@echo "  make logs          - 모든 서비스 로그 확인"
	@echo "  make logs-airflow  - Airflow 로그만 확인"
	@echo "  make logs-elk      - ELK 스택 로그만 확인"
	@echo "  make logs-postgres - PostgreSQL 로그만 확인"
	@echo ""
	@echo "🛠️  유틸리티:"
	@echo "  make shell         - Airflow 컨테이너 내부 접속"
	@echo "  make clean         - 컨테이너 및 볼륨 정리"
	@echo "  make clean-all     - 모든 Docker 리소스 정리"
	@echo ""
	@echo "🌐 접속 URL (Airflow 3.0.3):"
	@echo "  Airflow API:  http://localhost:$(AIRFLOW_PORT)"
	@echo "  Kibana:       http://localhost:$(KIBANA_PORT)"
	@echo "  PostgreSQL:   localhost:$(POSTGRES_PORT)"
	@echo ""
	@echo "🔑 기본 로그인 정보:"
	@echo "  Airflow - ID: admin, PW: admin123!"

# 전체 시스템 초기 설정
setup:
	@echo "🔧 전체 시스템 초기 설정 중..."
	@echo "📋 환경 변수 파일 복사..."
	@if [ ! -f .env ]; then cp env_sample.txt .env; echo "✅ .env 파일이 생성되었습니다"; else echo "⚠️  .env 파일이 이미 존재합니다"; fi
	@echo "🏗️  Docker 이미지 빌드 중..."
	docker-compose build
	@echo "🗄️  데이터베이스 설정 중..."
	docker-compose up -d $(DB_SERVICE) $(REDIS_SERVICE)
	@echo "⏳ 데이터베이스 준비 중..."
	sleep 15
	@echo "✈️  Airflow 초기화 중..."
	docker-compose up airflow-init
	@echo "✅ 전체 시스템 설정 완료!"
	@echo "💡 개발 환경을 시작하려면 'make dev' 를 실행하세요"

# Docker 이미지 빌드
build:
	@echo "🏗️  Docker 이미지 빌드 중..."
	docker-compose build

# Docker 이미지 빌드 (캐시 없이)
build-nc:
	@echo "🏗️  Docker 이미지 빌드 중 (캐시 없이)..."
	docker-compose build --no-cache

# 개발 환경 시작 (모든 서비스)
dev:
	@echo "🚀 개발 환경 시작 중..."
	docker-compose up -d
	@echo "✅ 개발 환경이 시작되었습니다!"
	@echo "🌐 Airflow: http://localhost:$(AIRFLOW_PORT)"
	@echo "🌐 Kibana:  http://localhost:$(KIBANA_PORT)"
	@echo "💡 로그를 보려면 'make logs' 를 실행하세요"

# 빌드 후 개발 환경 시작
dev-build:
	@echo "🏗️  빌드 후 개발 환경 시작 중..."
	docker-compose up -d --build
	@echo "✅ 개발 환경이 시작되었습니다!"
	@echo "🌐 Airflow: http://localhost:$(AIRFLOW_PORT)"
	@echo "🌐 Kibana:  http://localhost:$(KIBANA_PORT)"

# Airflow 서비스만 시작
airflow-up:
	@echo "✈️  Airflow 서비스 시작 중..."
	docker-compose up -d $(DB_SERVICE) $(REDIS_SERVICE) $(AIRFLOW_SERVICE) $(SCHEDULER_SERVICE) $(WORKER_SERVICE) airflow-triggerer
	@echo "✅ Airflow가 시작되었습니다 (포트: $(AIRFLOW_PORT))"

# Airflow 서비스 중지
airflow-down:
	@echo "✈️  Airflow 서비스 중지 중..."
	docker-compose stop $(AIRFLOW_SERVICE) $(SCHEDULER_SERVICE) $(WORKER_SERVICE) airflow-triggerer

# Airflow 로그 확인
airflow-logs:
	@echo "📋 Airflow 로그 확인 중..."
	docker-compose logs $(AIRFLOW_SERVICE) $(SCHEDULER_SERVICE)

# Airflow 웹서버 컨테이너 접속
airflow-shell:
	@echo "🐚 Airflow 웹서버 컨테이너 접속 중..."
	docker-compose exec $(AIRFLOW_SERVICE) bash

# Airflow 메타데이터 초기화
airflow-reset:
	@echo "🔄 Airflow 메타데이터 초기화 중..."
	docker-compose down
	docker-compose up airflow-init
	@echo "✅ Airflow가 초기화되었습니다"

# ELK Stack만 시작
elk-up:
	@echo "📊 ELK Stack 시작 중..."
	docker-compose up -d $(ELASTICSEARCH_SERVICE) $(KIBANA_SERVICE) $(LOGSTASH_SERVICE)
	@echo "✅ ELK Stack이 시작되었습니다"
	@echo "🌐 Kibana: http://localhost:$(KIBANA_PORT)"

# ELK Stack 중지
elk-down:
	@echo "📊 ELK Stack 중지 중..."
	docker-compose stop $(ELASTICSEARCH_SERVICE) $(KIBANA_SERVICE) $(LOGSTASH_SERVICE)

# ELK Stack 로그 확인
elk-logs:
	@echo "📋 ELK Stack 로그 확인 중..."
	docker-compose logs $(ELASTICSEARCH_SERVICE) $(KIBANA_SERVICE) $(LOGSTASH_SERVICE)

# ELK Stack 상태 확인
elk-status:
	@echo "📊 ELK Stack 상태 확인 중..."
	@echo "🔍 Elasticsearch 상태:"
	@curl -s http://localhost:$(ELASTICSEARCH_PORT)/_cluster/health?pretty || echo "❌ Elasticsearch 연결 실패"
	@echo "📈 Kibana 상태:"
	@curl -s http://localhost:$(KIBANA_PORT)/api/status || echo "❌ Kibana 연결 실패"

# Kibana 대시보드 리셋
kibana-reset:
	@echo "🔄 Kibana 대시보드 리셋 중..."
	docker-compose restart $(KIBANA_SERVICE)
	@echo "✅ Kibana가 재시작되었습니다"

# PostgreSQL 컨테이너만 시작
db-up:
	@echo "🗄️  PostgreSQL 컨테이너 시작 중..."
	docker-compose up -d $(DB_SERVICE)
	@echo "✅ PostgreSQL이 시작되었습니다 (포트: $(POSTGRES_PORT))"

# PostgreSQL 컨테이너 중지
db-down:
	@echo "🗄️  PostgreSQL 컨테이너 중지 중..."
	docker-compose stop $(DB_SERVICE)

# PostgreSQL 로그 확인
db-logs:
	@echo "📋 PostgreSQL 로그 확인 중..."
	docker-compose logs $(DB_SERVICE)

# PostgreSQL 콘솔 접속
db-shell:
	@echo "🐚 PostgreSQL 콘솔 접속 중..."
	@echo "💡 사용 가능한 데이터베이스: airflow, tech_trends"
	docker-compose exec $(DB_SERVICE) psql -U airflow -d airflow

# 데이터베이스 초기화
db-reset:
	@echo "🔄 데이터베이스 초기화 중..."
	docker-compose exec $(DB_SERVICE) psql -U airflow -d airflow -c "DROP DATABASE IF EXISTS tech_trends; CREATE DATABASE tech_trends;"
	@echo "✅ tech_trends 데이터베이스가 초기화되었습니다"

# DAG 활성화 및 데이터 수집 시작
start-pipeline:
	@echo "🔄 데이터 파이프라인 시작 중..."
	docker-compose exec $(AIRFLOW_SERVICE) airflow dags unpause hackernews_data_pipeline || echo "⚠️  DAG가 아직 없습니다"
	@echo "✅ 데이터 파이프라인이 활성화되었습니다"

# 데이터 파이프라인 중지
stop-pipeline:
	@echo "⏹️  데이터 파이프라인 중지 중..."
	docker-compose exec $(AIRFLOW_SERVICE) airflow dags pause hackernews_data_pipeline || echo "⚠️  DAG가 아직 없습니다"
	@echo "✅ 데이터 파이프라인이 중지되었습니다"

# DAG 수동 트리거
trigger-dag:
	@echo "🔄 DAG 수동 트리거 중..."
	docker-compose exec $(AIRFLOW_SERVICE) airflow dags trigger hackernews_data_pipeline || echo "⚠️  DAG가 아직 없습니다"
	@echo "✅ DAG가 트리거되었습니다"

# 샘플 데이터 생성 (개발용)
seed-data:
	@echo "🌱 샘플 데이터 생성 중..."
	@echo "⚠️  아직 구현되지 않았습니다"
	@echo "💡 향후 HackerNews 샘플 데이터 생성 스크립트 추가 예정"

# 모든 서비스 로그 확인
logs:
	@echo "📋 모든 서비스 로그 확인 중..."
	docker-compose logs --tail=100

# Airflow 로그만 확인
logs-airflow:
	@echo "📋 Airflow 로그 확인 중..."
	docker-compose logs $(AIRFLOW_SERVICE) $(SCHEDULER_SERVICE) $(WORKER_SERVICE)

# ELK 스택 로그만 확인
logs-elk:
	@echo "📋 ELK Stack 로그 확인 중..."
	docker-compose logs $(ELASTICSEARCH_SERVICE) $(KIBANA_SERVICE) $(LOGSTASH_SERVICE)

# PostgreSQL 로그만 확인
logs-postgres:
	@echo "📋 PostgreSQL 로그 확인 중..."
	docker-compose logs $(DB_SERVICE)

# 컨테이너 상태 확인
status:
	@echo "📊 컨테이너 상태 확인 중..."
	docker-compose ps

# Airflow 컨테이너 내부 접속
shell:
	@echo "🐚 Airflow 컨테이너 내부 접속 중..."
	docker-compose exec $(AIRFLOW_SERVICE) bash

# 모든 서비스 중지
stop:
	@echo "⏹️  모든 서비스 중지 중..."
	docker-compose down
	@echo "✅ 모든 서비스가 중지되었습니다"

# 모든 서비스 재시작
restart:
	@echo "🔄 모든 서비스 재시작 중..."
	docker-compose restart
	@echo "✅ 모든 서비스가 재시작되었습니다"

# 컨테이너 및 볼륨 정리
clean:
	@echo "🧹 컨테이너 및 볼륨 정리 중..."
	docker-compose down --volumes --remove-orphans
	@echo "✅ 정리 완료!"

# 모든 Docker 리소스 정리 (주의: 다른 프로젝트에도 영향)
clean-all:
	@echo "⚠️  모든 Docker 리소스 정리 중..."
	@echo "이 명령은 다른 프로젝트에도 영향을 줄 수 있습니다."
	@read -p "계속하시겠습니까? (y/N): " confirm && [ "$$confirm" = "y" ]
	docker system prune -a --volumes
	@echo "✅ 모든 Docker 리소스가 정리되었습니다"