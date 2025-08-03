-- Migration to add new task types to the tasks table
-- Run this in your Supabase SQL editor

-- Remove the old constraint
ALTER TABLE tasks DROP CONSTRAINT IF EXISTS tasks_task_type_check;

-- Add new constraint with all task types (original + new ones)
ALTER TABLE tasks ADD CONSTRAINT tasks_task_type_check 
CHECK (task_type IN (
  'follow_up', 
  'reminder', 
  'campaign', 
  'contact_crud', 
  'follow_up_sms', 
  'email_send_reply', 
  'reminder_call'
));