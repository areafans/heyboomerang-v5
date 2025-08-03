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

type TaskStats = {
  total: number
  needsInfo: number
  completedToday?: number
  averageResponseTime?: number
}

type PendingTasksResponse = {
  active: Task[]
  archived: Task[]
  stats: TaskStats
  lastSyncedAt?: string
}

// Helper function to get user from authorization header
async function getUserFromAuth(req: NextApiRequest) {
  const authHeader = req.headers.authorization
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return null
  }

  const token = authHeader.substring(7)
  const { data: authUser, error } = await supabaseAdmin.auth.getUser(token)
  
  if (error || !authUser.user) {
    return null
  }

  return authUser.user
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse<PendingTasksResponse | { error: string }>
) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  try {
    // Get authenticated user
    const authUser = await getUserFromAuth(req)
    if (!authUser) {
      return res.status(401).json({ error: 'Unauthorized' })
    }

    console.log('📋 Fetching pending tasks for user:', authUser.id)

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
        created_at
      `)
      .eq('user_id', authUser.id)
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
      originalTranscription: undefined // Will fetch separately if needed
    }))

    // Get completed tasks today count for stats (optional enhancement)
    const { count: completedToday } = await supabaseAdmin
      .from('tasks')
      .select('*', { count: 'exact', head: true })
      .eq('user_id', authUser.id)
      .eq('status', 'approved')
      .gte('approved_at', new Date().toISOString().split('T')[0]) // Today

    const stats: TaskStats = {
      total: tasks.length,
      needsInfo: tasks.filter(t => !t.contactPhone && !t.contactEmail).length,
      completedToday: completedToday || 0
    }

    res.status(200).json({
      active: tasks,
      archived: [], // Empty for now - could add archived tasks later
      stats,
      lastSyncedAt: new Date().toISOString()
    })

  } catch (error) {
    console.error('Error fetching pending tasks:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
}