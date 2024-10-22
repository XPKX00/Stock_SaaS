\c stock_data_db;

-- Define the action to be taken
DO $$
DECLARE
    action TEXT := 'create';  -- Set to 'create' to create tables, or 'delete' to drop tables
BEGIN

    -- Delete all tables
    IF action = 'delete' THEN

        -- Drop Indicator Types Table
        EXECUTE 'DROP TABLE IF EXISTS indicator_types CASCADE';

        -- Drop AI Models Table
        EXECUTE 'DROP TABLE IF EXISTS ai_models CASCADE';

        -- Drop User Tick Usage Table
        EXECUTE 'DROP TABLE IF EXISTS user_tick_usage CASCADE';

        -- Drop Sentiment Analysis Table
        EXECUTE 'DROP TABLE IF EXISTS sentiment_analysis CASCADE';

        -- Drop Predictions Table
        EXECUTE 'DROP TABLE IF EXISTS predictions CASCADE';

        -- Drop Indicators Table
        EXECUTE 'DROP TABLE IF EXISTS indicators CASCADE';

        -- Drop Stock Data Table
        EXECUTE 'DROP TABLE IF EXISTS stock_data CASCADE';

        -- Drop Users Table
        EXECUTE 'DROP TABLE IF EXISTS users CASCADE';

    -- Create all tables
    ELSIF action = 'create' THEN

        -- Users Table (Create this first to handle foreign key references)
        IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'users') THEN
            EXECUTE '
            CREATE TABLE users (
                user_id SERIAL PRIMARY KEY,
                username TEXT NOT NULL,
                email TEXT NOT NULL UNIQUE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )';
        END IF;

        -- Stock Data Table
        IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'stock_data') THEN
            EXECUTE '
            CREATE TABLE stock_data (
                stock_id SERIAL PRIMARY KEY,
                tenant_id UUID NOT NULL,  -- For multi-tenancy support
                ticker TEXT NOT NULL,
                timestamp TIMESTAMP NOT NULL,
                open NUMERIC,
                close NUMERIC,
                high NUMERIC,
                low NUMERIC,
                volume NUMERIC,
                user_id INTEGER REFERENCES users(user_id),
                CONSTRAINT stock_data_uniq UNIQUE (ticker, timestamp)  -- Ensure no duplicate entries for the same time and ticker
            )';
        END IF;

        -- Indicators Table
        IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'indicators') THEN
            EXECUTE '
            CREATE TABLE indicators (
                indicator_id SERIAL PRIMARY KEY,
                tenant_id UUID NOT NULL,  -- For multi-tenancy support
                user_id INTEGER REFERENCES users(user_id),
                ticker TEXT NOT NULL,
                timestamp TIMESTAMP NOT NULL,
                indicator_name TEXT,
                value NUMERIC
            )';
        END IF;

        -- Predictions Table
        IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'predictions') THEN
            EXECUTE '
            CREATE TABLE predictions (
                prediction_id SERIAL PRIMARY KEY,
                tenant_id UUID NOT NULL,  -- For multi-tenancy support
                user_id INTEGER REFERENCES users(user_id),
                ticker TEXT NOT NULL,
                timestamp TIMESTAMP NOT NULL,
                prediction JSONB NOT NULL,  -- Detailed prediction in JSON format
                model_version TEXT NOT NULL  -- Track AI model version
            )';
        END IF;

        -- Sentiment Analysis Table
        IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'sentiment_analysis') THEN
            EXECUTE '
            CREATE TABLE sentiment_analysis (
                sentiment_id SERIAL PRIMARY KEY,
                tenant_id UUID NOT NULL,  -- For multi-tenancy support
                user_id INTEGER REFERENCES users(user_id),
                ticker TEXT NOT NULL,
                timestamp TIMESTAMP NOT NULL,
                sentiment_score NUMERIC,
                sentiment_summary TEXT,
                source TEXT  -- Source of sentiment data (e.g., Twitter, Reddit)
            )';
        END IF;

        -- User Tick Usage Table
        IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'user_tick_usage') THEN
            EXECUTE '
            CREATE TABLE user_tick_usage (
                usage_id SERIAL PRIMARY KEY,
                user_id INTEGER REFERENCES users(user_id),
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                tick_count INTEGER DEFAULT 0,  -- Tracks tick count used
                month_year DATE NOT NULL  -- Month and year to ensure monthly tracking
            )';
        END IF;

        -- AI Models Table
        IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'ai_models') THEN
            EXECUTE '
            CREATE TABLE ai_models (
                ai_model_id SERIAL PRIMARY KEY,
                model_name TEXT NOT NULL,
                model_version TEXT,
                access_level TEXT CHECK (access_level IN (''basic'', ''pro'', ''premium'')) NOT NULL  -- Access level restrictions
            )';
        END IF;

        -- Indicator Types Table
        IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'indicator_types') THEN
            EXECUTE '
            CREATE TABLE indicator_types (
                indicator_type_id SERIAL PRIMARY KEY,
                name TEXT NOT NULL UNIQUE,
                description TEXT
            )';
        END IF;

    END IF;

END $$;
