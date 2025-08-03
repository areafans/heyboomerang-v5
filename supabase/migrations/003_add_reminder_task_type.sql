-- Migration: Add 'reminder' task type to support general reminders
-- Date: 2025-08-03
-- Reason: Distinguish between general reminders and call reminders

-- Drop existing constraint
ALTER TABLE tasks DROP CONSTRAINT IF EXISTS tasks_task_type_check;

-- Add updated constraint with 'reminder' type
ALTER TABLE tasks ADD CONSTRAINT tasks_task_type_check 
  CHECK (task_type IN ('follow_up', 'reminder', 'campaign', 'contact_crud', 'follow_up_sms', 'email_send_reply', 'reminder_call'));

-- Also update delivery method constraint if needed
ALTER TABLE tasks DROP CONSTRAINT IF EXISTS tasks_delivery_method_check;
ALTER TABLE tasks ADD CONSTRAINT tasks_delivery_method_check 
  CHECK (delivery_method IN ('sms', 'email', 'both', 'internal', 'phone'));