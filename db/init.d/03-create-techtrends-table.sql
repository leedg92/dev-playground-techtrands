-- ========================================
-- 터미널 상태 모니터링 시스템 데이터베이스 스키마
-- ========================================

-- 데이터베이스 사용
USE `tech_trends`;



CREATE table tech_trends.tech_trends_items (
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

create table if not exists tech_trends.tech_dictionary (
	keyword varchar(100) NOT NULL,
	category varchar(100) CHECK (category IN ('language','framework','tool','platform','concept')) NOT NULL,
	use_yn varchar(1) default 'Y',
	CONSTRAINT tech_dictionary_pkey PRIMARY KEY (keyword)
);
