-- ========================================
-- 터미널 상태 모니터링 시스템 데이터베이스 스키마
-- ========================================

-- tech_trends 데이터베이스로 연결
\c tech_trends;

-- tech_trends 스키마 생성
CREATE SCHEMA IF NOT EXISTS tech_trends;

-- 스키마 생성 후 techtrends 사용자에게 권한 부여
GRANT ALL PRIVILEGES ON SCHEMA tech_trends TO techtrends;
GRANT USAGE ON SCHEMA tech_trends TO techtrends;

-- 테이블 생성
CREATE TABLE tech_trends.tech_trends_items (
	id int4 NOT NULL,
	item_type varchar(20) NULL,
	text_content text NULL,
	sentiment_score float8 NULL,
	sentiment_label varchar(20) NULL,
	extracted_keyword varchar(100) NULL,
	author varchar(50) NULL,
	created_at timestamp NULL,
	score int4 NULL,
	parent_id int8 NULL,
	root_story_id int8 NULL,
	CONSTRAINT tech_trends_items_pkey PRIMARY KEY (id, extracted_keyword)
);

CREATE TABLE IF NOT EXISTS tech_trends.tech_dictionary (
	keyword varchar(100) NOT NULL,
	category varchar(100) CHECK (category IN ('language','framework','tool','platform','concept')) NOT NULL,
	use_yn varchar(1) DEFAULT 'Y',
	CONSTRAINT tech_dictionary_pkey PRIMARY KEY (keyword)
);

-- 테이블 생성 후 techtrends 사용자에게 테이블 권한 부여
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA tech_trends TO techtrends;

-- 앞으로 생성될 테이블들에 대한 기본 권한 설정
ALTER DEFAULT PRIVILEGES IN SCHEMA tech_trends GRANT ALL PRIVILEGES ON TABLES TO techtrends;

-- 테이블 및 권한 설정 완료 로그
\echo 'Tables created and privileges granted to techtrends user';