import type { NextApiRequest, NextApiResponse } from 'next'
import { supabaseAdmin } from '@/lib/supabase'

type Task = {
  id: string
  userId: string
  captureId: string
  type: 'follow_up_sms' | 'reminder_call' | 'campaign' | 'contact_crud' | 'email_send_reply'
  status: 'pending' | 'approved' | 'skipped' | 'sent' | 'delivered' | 'failed'
  contactId?: string
  contactName?: string
  message: string
  originalTranscription: string
  scheduledFor?: string
  createdAt: string
  archivedAt?: string
  dismissedAt?: string
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

    // Query pending tasks from database - get all fields for iOS compatibility
    const { data: tasksData, error } = await supabaseAdmin
      .from('tasks')
      .select(`
        id,
        user_id,
        capture_id,
        contact_id,
        contact_name,
        task_type,
        message,
        scheduled_for,
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

    // Get capture transcriptions separately to avoid join complexities
    const captureIds = tasksData?.map(task => task.capture_id).filter(Boolean) || []
    const { data: capturesData } = await supabaseAdmin
      .from('captures')
      .select('id, transcription')
      .in('id', captureIds)

    // Create a map of capture_id -> transcription
    const captureMap = new Map(
      (capturesData || []).map(capture => [capture.id, capture.transcription])
    )

    console.log('📊 Raw tasks data from database:', JSON.stringify(tasksData, null, 2))

    // Transform database results to match iOS AppTask format
    const tasks: Task[] = (tasksData || []).map(task => ({
      id: task.id,
      userId: task.user_id,
      captureId: task.capture_id,
      type: task.task_type as Task['type'],
      status: task.status as Task['status'],
      contactId: task.contact_id || undefined,
      contactName: task.contact_name || undefined,
      message: task.message,
      originalTranscription: captureMap.get(task.capture_id) || '',
      scheduledFor: task.scheduled_for || undefined,
      createdAt: task.created_at,
      archivedAt: undefined,
      dismissedAt: undefined
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
      needsInfo: tasks.filter(t => !t.contactName).length, // Tasks without contact info
      completedToday: completedToday || 0
    }

    console.log('🔄 Transformed tasks for iOS:', JSON.stringify(tasks, null, 2))
    console.log('📈 Task stats:', stats)

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