-- ========================================
-- 터미널 상태 모니터링 시스템 데이터베이스 스키마
-- ========================================

-- 데이터베이스 사용
USE `techtrends`;


CREATE TABLE tech_trends_items (
    id BIGINT PRIMARY KEY,                  -- HN 아이템 ID
    item_type VARCHAR(20),                  -- 'story' or 'comment'
    text_content TEXT,                      -- 분석할 텍스트 (제목+본문)
    
    -- 감성분석 결과
    sentiment_score FLOAT,                  -- compound 점수 (-1 ~ 1)
    sentiment_label VARCHAR(20),            -- positive/negative/neutral
    
    -- 키워드 분석 결과 (JSON 형식)
    extracted_keywords JSONB,               -- {"keyword": score, ...}
    
    -- 메타데이터
    author VARCHAR(50),                     -- 작성자
    created_at TIMESTAMP,                   -- 작성시간
    score INTEGER,                          -- HN 점수
    
    -- 컨텍스트 (필요시)
    parent_id BIGINT,                       -- 댓글인 경우 부모 ID
    root_story_id BIGINT                    -- 최상위 스토리 ID
);


-- 데이터베이스 구조 및 데이터 저장 방법

-- 1. 테이블 구조:
-- CREATE TABLE content_items (
--     id BIGINT PRIMARY KEY,                  -- HN 아이템 ID
--     item_type VARCHAR(20),                  -- 'story' or 'comment'
--     text_content TEXT,                      -- 분석할 텍스트 (제목+본문)
    
--     -- 감성분석 결과
--     sentiment_score FLOAT,                  -- compound 점수 (-1 ~ 1)
--     sentiment_label VARCHAR(20),            -- positive/negative/neutral
    
--     -- 키워드 분석 결과 (JSON 형식)
--     extracted_keywords JSONB,               -- {"keyword": score, ...}
    
--     -- 메타데이터
--     author VARCHAR(50),                     -- 작성자
--     created_at TIMESTAMP,                   -- 작성시간
--     score INTEGER,                          -- HN 점수
    
--     -- 컨텍스트 (필요시)
--     parent_id BIGINT,                       -- 댓글인 경우 부모 ID
--     root_story_id BIGINT                    -- 최상위 스토리 ID
-- );