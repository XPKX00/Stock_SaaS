\c makerkit_db;

-- Define the action to be taken (create or drop)
DO $$
DECLARE
    action TEXT := 'create';  -- Set to 'create' to create tables, or 'delete' to drop tables
BEGIN

    -- Handle table operations
    IF action = 'delete' THEN
        -- Drop Tables
        EXECUTE 'DROP TABLE IF EXISTS users CASCADE';
        EXECUTE 'DROP TABLE IF EXISTS teams CASCADE';
        EXECUTE 'DROP TABLE IF EXISTS subscriptions CASCADE';
        EXECUTE 'DROP TABLE IF EXISTS user_team_memberships CASCADE';
        EXECUTE 'DROP TABLE IF EXISTS user_api_keys CASCADE';
    ELSEIF action = 'create' THEN

        -- Users Table
        IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'users') THEN
            EXECUTE '
            CREATE TABLE users (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                email TEXT UNIQUE NOT NULL,
                hashed_password TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )';
        END IF;

        -- Teams Table
        IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'teams') THEN
            EXECUTE '
            CREATE TABLE teams (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                name TEXT NOT NULL,
                owner_id UUID REFERENCES users(id) ON DELETE SET NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )';
        END IF;

        -- User-Team Memberships Table
        IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'user_team_memberships') THEN
            EXECUTE '
            CREATE TABLE user_team_memberships (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                user_id UUID REFERENCES users(id) ON DELETE CASCADE,
                team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
                role TEXT CHECK (role IN (''admin'', ''member'')) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )';
        END IF;

        -- Subscriptions Table
        IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'subscriptions') THEN
            EXECUTE '
            CREATE TABLE subscriptions (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
                plan TEXT CHECK (plan IN (''free'', ''pro'', ''enterprise'')) NOT NULL,
                status TEXT CHECK (status IN (''active'', ''inactive'')) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )';
        END IF;

        -- User API Keys Table
        IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'user_api_keys') THEN
            EXECUTE '
            CREATE TABLE user_api_keys (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                user_id UUID REFERENCES users(id) ON DELETE CASCADE,
                api_provider TEXT NOT NULL,
                api_key TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )';
        END IF;

        -- Add additional necessary tables here as required for Makerkit Turbo...
    END IF;

END $$;

-- Grant Permissions to a Specific Database User
DO $$
BEGIN
    -- Ensure the application user exists
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'makerkit_user') THEN
        EXECUTE 'CREATE ROLE makerkit_user LOGIN PASSWORD ''securepassword''';
    END IF;

    -- Grant Permissions
    EXECUTE 'GRANT CONNECT ON DATABASE makerkit_db TO makerkit_user';
    EXECUTE 'GRANT USAGE ON SCHEMA public TO makerkit_user';
    EXECUTE 'GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO makerkit_user';
    EXECUTE 'GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO makerkit_user';
END $$;
