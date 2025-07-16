-- ========================================
-- 터미널 상태 모니터링 시스템 데이터베이스 스키마
-- ========================================

-- 데이터베이스 사용
USE `tech_trends`;


CREATE TABLE IF NOT EXISTS tech_trends.tech_trends_items (
	id int4 NOT NULL,
	item_type varchar(20) NULL,
	text_content text NULL,
	sentiment_score float8 NULL,
	sentiment_label varchar(20) NULL,
	extracted_keywords varchar(100) NULL,
	author varchar(50) NULL,
	created_at timestamp NULL,
	score int4 NULL,
	parent_id int8 NULL,
	root_story_id int8 NULL,
	CONSTRAINT tech_trends_items_pkey PRIMARY KEY (id)
);
