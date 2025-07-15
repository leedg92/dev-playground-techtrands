-- ============================================================================
-- techtrends 사용자 생성 및 권한 부여
-- ============================================================================

-- techtrends 사용자 생성
CREATE USER techtrends WITH PASSWORD 'techtrends123!';

-- tech_trends 데이터베이스에 대한 모든 권한 부여
GRANT ALL PRIVILEGES ON DATABASE tech_trends TO techtrends;

-- 데이터베이스 소유자 변경
ALTER DATABASE tech_trends OWNER TO techtrends;

-- 사용자 생성 완료 로그
\echo 'User techtrends created and granted privileges on tech_trends database'; 