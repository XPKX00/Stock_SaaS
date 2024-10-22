\c user_subscription_db;

-- Users Table (must be created first to be referenced by other tables)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'users') THEN
    CREATE TABLE users (
      user_id SERIAL PRIMARY KEY,
      tenant_id UUID NOT NULL,  -- For multi-tenancy support
      username TEXT UNIQUE NOT NULL,
      email TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      last_login TIMESTAMP,
      account_status TEXT CHECK (account_status IN ('active', 'suspended', 'deleted'))
    );
  END IF;
END $$;

-- Subscriptions Table (must be created before referencing in user_subscriptions)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'subscriptions') THEN
    CREATE TABLE subscriptions (
      subscription_id SERIAL PRIMARY KEY,
      plan_name TEXT NOT NULL,
      description TEXT,
      price NUMERIC NOT NULL,  -- Monthly subscription price
      tick_limit INTEGER,  -- Number of tick data allowed per month
      ai_model_access TEXT[] DEFAULT '{}'  -- Array of AI model access levels (e.g., 'basic', 'pro')
    );
  END IF;
END $$;

-- AI Models Table (must be created before referencing in user_ai_model_access)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'ai_models') THEN
    CREATE TABLE ai_models (
      ai_model_id SERIAL PRIMARY KEY,
      model_name TEXT NOT NULL,
      model_version TEXT,
      access_level TEXT CHECK (access_level IN ('basic', 'pro', 'premium')) NOT NULL
    );
  END IF;
END $$;

-- Orders Table (must be created before referencing in audit_logs)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'orders') THEN
    CREATE TABLE orders (
      order_id SERIAL PRIMARY KEY,
      tenant_id UUID NOT NULL,  -- For multi-tenancy support
      user_id INTEGER REFERENCES users(user_id),
      ticker TEXT NOT NULL,
      order_type TEXT CHECK (order_type IN ('market', 'limit')) NOT NULL,
      quantity NUMERIC NOT NULL,
      price NUMERIC NOT NULL,
      price2 NUMERIC NOT NULL,
      timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      status TEXT CHECK (status IN ('pending', 'executed', 'canceled')) NOT NULL
    );
  END IF;
END $$;

-- User Preferences Table
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'user_preferences') THEN
    CREATE TABLE user_preferences (
      preference_id SERIAL PRIMARY KEY,
      user_id INTEGER REFERENCES users(user_id),
      strategy JSONB NOT NULL,  -- User-defined trading strategy
      notification_preferences JSONB  -- Notification settings, e.g., SMS, email
    );
  END IF;
END $$;

-- User Subscriptions Table
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'user_subscriptions') THEN
    CREATE TABLE user_subscriptions (
      user_subscription_id SERIAL PRIMARY KEY,
      user_id INTEGER REFERENCES users(user_id),
      subscription_id INTEGER REFERENCES subscriptions(subscription_id),
      start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      end_date TIMESTAMP,
      is_active BOOLEAN DEFAULT TRUE
    );
  END IF;
END $$;

-- User AI Model Access Table
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'user_ai_model_access') THEN
    CREATE TABLE user_ai_model_access (
      user_ai_model_access_id SERIAL PRIMARY KEY,
      user_id INTEGER REFERENCES users(user_id),
      ai_model_id INTEGER REFERENCES ai_models(ai_model_id),
      subscription_id INTEGER REFERENCES subscriptions(subscription_id),
      granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  END IF;
END $$;

-- Audit Logs Table
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'audit_logs') THEN
    CREATE TABLE audit_logs (
      audit_id SERIAL PRIMARY KEY,
      order_id INTEGER REFERENCES orders(order_id),
      change_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      change_details JSONB  -- Details about the change made to the order
    );
  END IF;
END $$;
