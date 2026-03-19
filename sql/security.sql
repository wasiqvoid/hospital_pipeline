-- ============================================================
-- EAS 550 — Hospital Management Database
-- security.sql | Role-Based Access Control (RBAC)
-- Phase 1 Bonus — Step 1.4
-- ============================================================

-- Drop roles if they exist (idempotent)
-- ============================================================
-- security.sql (FIXED)
-- ============================================================

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

-- ANALYST ROLE (READ ONLY)
CREATE ROLE hospital_analyst
    NOSUPERUSER NOCREATEDB NOCREATEROLE;

GRANT CONNECT ON DATABASE neondb TO hospital_analyst;
GRANT USAGE ON SCHEMA public TO hospital_analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO hospital_analyst;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO hospital_analyst;

-- APP USER ROLE (READ + WRITE)
CREATE ROLE hospital_app_user
    NOSUPERUSER NOCREATEDB NOCREATEROLE;

GRANT CONNECT ON DATABASE neondb TO hospital_app_user;
GRANT USAGE ON SCHEMA public TO hospital_app_user;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO hospital_app_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO hospital_app_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE ON TABLES TO hospital_app_user;

REVOKE ALL ON SCHEMA public FROM PUBLIC;