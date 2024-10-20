\c stock_data_db;

-- Stock Data Table
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'stock_data') THEN
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
      CONSTRAINT stock_data_uniq UNIQUE (ticker, timestamp)  -- Ensure no duplicate entries for same time and ticker
    );
  END IF;
END $$;

-- Indicators Table
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'indicators') THEN
    CREATE TABLE indicators (
      indicator_id SERIAL PRIMARY KEY,
      tenant_id UUID NOT NULL,  -- For multi-tenancy support
      user_id INTEGER REFERENCES users(user_id),
      ticker TEXT NOT NULL,
      timestamp TIMESTAMP NOT NULL,
      indicator_name TEXT,
      value NUMERIC
    );
  END IF;
END $$;
-- Predictions Table
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'predictions') THEN
    CREATE TABLE predictions (
      prediction_id SERIAL PRIMARY KEY,
      tenant_id UUID NOT NULL,  -- For multi-tenancy support
      user_id INTEGER REFERENCES users(user_id),
      ticker TEXT NOT NULL,
      timestamp TIMESTAMP NOT NULL,
      prediction JSONB NOT NULL,  -- Detailed prediction in JSON format
      model_version TEXT NOT NULL  -- Track AI model version
    );
  END IF;
END $$;

-- Sentiment Analysis Table
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'sentiment_analysis') THEN
    CREATE TABLE sentiment_analysis (
      sentiment_id SERIAL PRIMARY KEY,
      tenant_id UUID NOT NULL,  -- For multi-tenancy support
      user_id INTEGER REFERENCES users(user_id),
      ticker TEXT NOT NULL,
      timestamp TIMESTAMP NOT NULL,
      sentiment_score NUMERIC,
      sentiment_summary TEXT,
      source TEXT  -- Source of sentiment data (e.g., Twitter, Reddit)
    );
  END IF;
END $$;

-- User Tick Usage Table
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'user_tick_usage') THEN
    CREATE TABLE user_tick_usage (
      usage_id SERIAL PRIMARY KEY,
      user_id INTEGER REFERENCES users(user_id),
      timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      tick_count INTEGER DEFAULT 0,  -- Tracks tick count used
      month_year DATE NOT NULL  -- Month and year to ensure monthly tracking
    );
  END IF;
END $$;

-- AI Models Table
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'ai_models') THEN
    CREATE TABLE ai_models (
      ai_model_id SERIAL PRIMARY KEY,
      model_name TEXT NOT NULL,
      model_version TEXT,
      access_level TEXT CHECK (access_level IN ('basic', 'pro', 'premium')) NOT NULL  -- Access level restrictions
    );
  END IF;
END $$;
-- Indicator Types Table
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'indicator_types') THEN
    CREATE TABLE indicator_types (
      indicator_type_id SERIAL PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      description TEXT
    );
  END IF;
END $$;
```

