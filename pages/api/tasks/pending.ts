import type { NextApiRequest, NextApiResponse } from 'next'
import { supabaseAdmin } from '@/lib/supabase'

type Task = {
  id: string
  type: 'follow_up' | 'reminder' | 'campaign'
  contactName: string
  contactPhone?: string
  contactEmail?: string
  message: string
  timing: 'immediate' | 'end_of_day' | 'tomorrow' | 'next_week'
  status: 'pending' | 'approved' | 'skipped'
  createdAt: string
  originalTranscription?: string
}

type PendingTasksResponse = {
  success: boolean
  tasks: Task[]
  count: number
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse<PendingTasksResponse | { error: string }>
) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  try {
    const { userId } = req.query

    if (!userId) {
      return res.status(400).json({ error: 'Missing userId parameter' })
    }

    // Query pending tasks from database
    const { data: tasksData, error } = await supabaseAdmin
      .from('tasks')
      .select(`
        id,
        task_type,
        contact_name,
        contact_phone,
        contact_email,
        message,
        timing,
        status,
        created_at,
        captures!inner(transcription)
      `)
      .eq('user_id', userId)
      .eq('status', 'pending')
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Database error:', error)
      return res.status(500).json({ error: 'Database query failed' })
    }

    // Transform database results to match API format
    const tasks: Task[] = (tasksData || []).map(task => ({
      id: task.id,
      type: task.task_type as Task['type'],
      contactName: task.contact_name,
      contactPhone: task.contact_phone || undefined,
      contactEmail: task.contact_email || undefined,
      message: task.message,
      timing: task.timing as Task['timing'],
      status: task.status as Task['status'],
      createdAt: task.created_at,
      originalTranscription: task.captures?.transcription || undefined
    }))

    res.status(200).json({
      success: true,
      tasks,
      count: tasks.length
    })

  } catch (error) {
    console.error('Error fetching pending tasks:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
}