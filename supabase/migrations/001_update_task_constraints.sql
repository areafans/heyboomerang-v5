-- Migration: Update task_type and delivery_method constraints
-- Date: 2025-08-03
-- Reason: Support new task types from OpenAI function calling

-- Drop existing constraints
ALTER TABLE tasks DROP CONSTRAINT IF EXISTS tasks_task_type_check;
ALTER TABLE tasks DROP CONSTRAINT IF EXISTS tasks_delivery_method_check;

-- Add updated constraints with new task types
ALTER TABLE tasks ADD CONSTRAINT tasks_task_type_check 
  CHECK (task_type IN ('follow_up', 'reminder', 'campaign', 'contact_crud', 'follow_up_sms', 'email_send_reply', 'reminder_call'));

-- Add updated delivery method constraint
ALTER TABLE tasks ADD CONSTRAINT tasks_delivery_method_check 
  CHECK (delivery_method IN ('sms', 'email', 'both', 'internal', 'phone'));