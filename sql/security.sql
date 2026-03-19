-- ============================================================
-- EAS 550 — Hospital Management Database
-- security.sql | Role-Based Access Control (RBAC)
-- Phase 1 Bonus — Step 1.4
-- ============================================================

-- Drop roles if they exist (idempotent)
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'hospital_analyst') THEN
        DROP ROLE hospital_analyst;
    END IF;
    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'hospital_app_user') THEN
        DROP ROLE hospital_app_user;
    END IF;
END
$$;

-- ─────────────────────────────────────────
-- ROLE 1: hospital_analyst
-- READ-ONLY — for BI tools and reporting
-- ─────────────────────────────────────────
CREATE ROLE hospital_analyst
    NOSUPERUSER NOCREATEDB NOCREATEROLE
    LOGIN PASSWORD 'analyst_password_change_me';

GRANT CONNECT ON DATABASE neondb          TO hospital_analyst;
GRANT USAGE   ON SCHEMA public            TO hospital_analyst;
GRANT SELECT  ON ALL TABLES IN SCHEMA public TO hospital_analyst;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO hospital_analyst;

-- ─────────────────────────────────────────
-- ROLE 2: hospital_app_user
-- READ + WRITE — for Streamlit/FastAPI app
-- ─────────────────────────────────────────
CREATE ROLE hospital_app_user
    NOSUPERUSER NOCREATEDB NOCREATEROLE
    LOGIN PASSWORD 'appuser_password_change_me';

GRANT CONNECT  ON DATABASE neondb             TO hospital_app_user;
GRANT USAGE    ON SCHEMA public               TO hospital_app_user;
GRANT SELECT, INSERT, UPDATE
               ON ALL TABLES IN SCHEMA public TO hospital_app_user;
GRANT USAGE, SELECT
               ON ALL SEQUENCES IN SCHEMA public TO hospital_app_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE ON TABLES    TO hospital_app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT USAGE, SELECT          ON SEQUENCES TO hospital_app_user;

-- Revoke public access (security best practice)
REVOKE ALL ON SCHEMA public FROM PUBLIC;
