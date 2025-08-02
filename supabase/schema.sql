-- Boomerang Database Schema
-- Voice-first task management for small service businesses

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  business_name TEXT NOT NULL,
  business_type TEXT NOT NULL,
  business_description TEXT,
  phone_number TEXT,
  timezone TEXT DEFAULT 'America/New_York',
  subscription_status TEXT DEFAULT 'trial' CHECK (subscription_status IN ('trial', 'active', 'inactive', 'canceled')),
  trial_ends_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '7 days'),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Contacts table
CREATE TABLE contacts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  phone_number TEXT,
  email TEXT,
  notes TEXT,
  relationship TEXT, -- 'client', 'prospect', 'vendor', 'partner'
  last_contact_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, name)
);

-- Voice captures table
CREATE TABLE captures (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  transcription TEXT NOT NULL,
  audio_duration_seconds INTEGER,
  captured_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  processed_at TIMESTAMP WITH TIME ZONE,
  processing_status TEXT DEFAULT 'pending' CHECK (processing_status IN ('pending', 'processing', 'completed', 'failed')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tasks table
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  capture_id UUID REFERENCES captures(id) ON DELETE SET NULL,
  contact_id UUID REFERENCES contacts(id) ON DELETE SET NULL,
  contact_name TEXT NOT NULL, -- Denormalized for cases where contact doesn't exist yet  
  contact_phone TEXT,
  contact_email TEXT,
  task_type TEXT NOT NULL CHECK (task_type IN ('follow_up', 'reminder', 'campaign')),
  message TEXT NOT NULL,
  timing TEXT NOT NULL CHECK (timing IN ('immediate', 'end_of_day', 'tomorrow', 'next_week', 'custom')),
  scheduled_for TIMESTAMP WITH TIME ZONE,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'skipped', 'sent', 'delivered', 'failed')),
  delivery_method TEXT CHECK (delivery_method IN ('sms', 'email', 'both')),
  approved_at TIMESTAMP WITH TIME ZONE,
  sent_at TIMESTAMP WITH TIME ZONE,
  delivered_at TIMESTAMP WITH TIME ZONE,
  expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '7 days'),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Messages table (for tracking sent messages)
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  contact_id UUID REFERENCES contacts(id) ON DELETE SET NULL,
  message_type TEXT NOT NULL CHECK (message_type IN ('sms', 'email')),
  recipient TEXT NOT NULL, -- phone number or email
  content TEXT NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'delivered', 'failed', 'bounced')),
  external_id TEXT, -- Twilio message SID or SendGrid message ID
  sent_at TIMESTAMP WITH TIME ZONE,
  delivered_at TIMESTAMP WITH TIME ZONE,
  failed_at TIMESTAMP WITH TIME ZONE,
  failure_reason TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User context table (for AI learning)
CREATE TABLE user_context (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  context_type TEXT NOT NULL CHECK (context_type IN ('business_info', 'messaging_style', 'contact_patterns', 'timing_preferences')),
  context_data JSONB NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, context_type)
);

-- Contact insights table (for AI contact matching)
CREATE TABLE contact_insights (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
  insight_type TEXT NOT NULL CHECK (insight_type IN ('interaction_frequency', 'preferred_contact_method', 'response_patterns', 'project_history')),
  insight_data JSONB NOT NULL,
  confidence_score DECIMAL(3,2) CHECK (confidence_score >= 0 AND confidence_score <= 1),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, contact_id, insight_type)
);

-- Indexes for performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_contacts_user_id ON contacts(user_id);
CREATE INDEX idx_contacts_name ON contacts(user_id, name);
CREATE INDEX idx_captures_user_id_created ON captures(user_id, created_at DESC);
CREATE INDEX idx_tasks_user_id_status ON tasks(user_id, status);
CREATE INDEX idx_tasks_scheduled_for ON tasks(scheduled_for) WHERE status = 'approved';
CREATE INDEX idx_tasks_expires_at ON tasks(expires_at) WHERE status = 'pending';
CREATE INDEX idx_messages_task_id ON messages(task_id);
CREATE INDEX idx_messages_status ON messages(status);
CREATE INDEX idx_user_context_user_id ON user_context(user_id);
CREATE INDEX idx_contact_insights_user_contact ON contact_insights(user_id, contact_id);

-- Row Level Security (RLS) policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE captures ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_context ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_insights ENABLE ROW LEVEL SECURITY;

-- Users can only access their own data
CREATE POLICY users_own_data ON users FOR ALL USING (auth.uid() = id);
CREATE POLICY contacts_own_data ON contacts FOR ALL USING (auth.uid() = user_id);
CREATE POLICY captures_own_data ON captures FOR ALL USING (auth.uid() = user_id);
CREATE POLICY tasks_own_data ON tasks FOR ALL USING (auth.uid() = user_id);
CREATE POLICY messages_own_data ON messages FOR ALL USING (auth.uid() = user_id);
CREATE POLICY user_context_own_data ON user_context FOR ALL USING (auth.uid() = user_id);
CREATE POLICY contact_insights_own_data ON contact_insights FOR ALL USING (auth.uid() = user_id);

-- Functions for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_contacts_updated_at BEFORE UPDATE ON contacts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to clean up expired tasks
CREATE OR REPLACE FUNCTION cleanup_expired_tasks()
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM tasks 
  WHERE status = 'pending' 
    AND expires_at < NOW();
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Sample data for development (can be removed in production)
-- INSERT INTO users (id, email, business_name, business_type, business_description) VALUES 
-- ('550e8400-e29b-41d4-a716-446655440000', 'mike@mikesconstruction.com', 'Mike''s Construction', 'General Contracting', 'Full-service construction and renovation company');

-- INSERT INTO contacts (user_id, name, phone_number, relationship) VALUES 
-- ('550e8400-e29b-41d4-a716-446655440000', 'Sarah Johnson', '+1555123456', 'client'),
-- ('550e8400-e29b-41d4-a716-446655440000', 'Mike Davis', '+1555987654', 'prospect'),
-- ('550e8400-e29b-41d4-a716-446655440000', 'Lisa Chen', '+1555555555', 'client');