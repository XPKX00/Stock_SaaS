-- Define the action to be taken
DO $$
DECLARE
    action TEXT := 'delete';  -- Set to 'create' to create tables, or 'delete' to drop tables
BEGIN

    -- Delete all tables
    IF action = 'delete' THEN

        -- Drop Audit Logs Table
        EXECUTE 'DROP TABLE IF EXISTS audit_logs CASCADE';

        -- Drop User AI Model Access Table
        EXECUTE 'DROP TABLE IF EXISTS user_ai_model_access CASCADE';

        -- Drop User Subscriptions Table
        EXECUTE 'DROP TABLE IF EXISTS user_subscriptions CASCADE';

        -- Drop User Preferences Table
        EXECUTE 'DROP TABLE IF EXISTS user_preferences CASCADE';

        -- Drop Orders Table
        EXECUTE 'DROP TABLE IF EXISTS orders CASCADE';

        -- Drop AI Models Table
        EXECUTE 'DROP TABLE IF EXISTS ai_models CASCADE';

        -- Drop Subscriptions Table
        EXECUTE 'DROP TABLE IF EXISTS subscriptions CASCADE';

        -- Drop Users Table
        EXECUTE 'DROP TABLE IF EXISTS users CASCADE';

    -- Create all tables
    ELSIF action = 'create' THEN

        -- Users Table
        IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'users') THEN
            EXECUTE '
            CREATE TABLE users (
                user_id SERIAL PRIMARY KEY,
                tenant_id UUID NOT NULL,  -- For multi-tenancy support
                username TEXT UNIQUE NOT NULL,
                email TEXT UNIQUE NOT NULL,
                password_hash TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                last_login TIMESTAMP,
                account_status TEXT CHECK (account_status IN (''active'', ''suspended'', ''deleted''))
            )';
        END IF;

        -- Subscriptions Table
        IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'subscriptions') THEN
            EXECUTE '
            CREATE TABLE subscriptions (
                subscription_id SERIAL PRIMARY KEY,
                plan_name TEXT NOT NULL,
                description TEXT,
                price NUMERIC NOT NULL,
                tick_limit INTEGER,
                ai_model_access TEXT[] DEFAULT ''{}''
            )';
        END IF;

        -- AI Models Table
        IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'ai_models') THEN
            EXECUTE '
            CREATE TABLE ai_models (
                ai_model_id SERIAL PRIMARY KEY,
                model_name TEXT NOT NULL,
                model_version TEXT,
                access_level TEXT CHECK (access_level IN (''basic'', ''pro'', ''premium'')) NOT NULL
            )';
        END IF;

        -- Orders Table
        IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'orders') THEN
            EXECUTE '
            CREATE TABLE orders (
                order_id SERIAL PRIMARY KEY,
                tenant_id UUID NOT NULL,
                user_id INTEGER REFERENCES users(user_id),
                ticker TEXT NOT NULL,
                order_type TEXT CHECK (order_type IN (''market'', ''limit'')) NOT NULL,
                quantity NUMERIC NOT NULL,
                price NUMERIC NOT NULL,
                price2 NUMERIC NOT NULL,
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                status TEXT CHECK (status IN (''pending'', ''executed'', ''canceled'')) NOT NULL
            )';
        END IF;

        -- User Preferences Table
        IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'user_preferences') THEN
            EXECUTE '
            CREATE TABLE user_preferences (
                preference_id SERIAL PRIMARY KEY,
                user_id INTEGER REFERENCES users(user_id),
                strategy JSONB NOT NULL,
                notification_preferences JSONB
            )';
        END IF;

        -- User Subscriptions Table
        IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'user_subscriptions') THEN
            EXECUTE '
            CREATE TABLE user_subscriptions (
                user_subscription_id SERIAL PRIMARY KEY,
                user_id INTEGER REFERENCES users(user_id),
                subscription_id INTEGER REFERENCES subscriptions(subscription_id),
                start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                end_date TIMESTAMP,
                is_active BOOLEAN DEFAULT TRUE
            )';
        END IF;

        -- User AI Model Access Table
        IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'user_ai_model_access') THEN
            EXECUTE '
            CREATE TABLE user_ai_model_access (
                user_ai_model_access_id SERIAL PRIMARY KEY,
                user_id INTEGER REFERENCES users(user_id),
                ai_model_id INTEGER REFERENCES ai_models(ai_model_id),
                subscription_id INTEGER REFERENCES subscriptions(subscription_id),
                granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )';
        END IF;

        -- Audit Logs Table
        IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'audit_logs') THEN
            EXECUTE '
            CREATE TABLE audit_logs (
                audit_id SERIAL PRIMARY KEY,
                order_id INTEGER REFERENCES orders(order_id),
                change_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                change_details JSONB
            )';
        END IF;

    END IF;

END $$;
