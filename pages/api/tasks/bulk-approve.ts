import type { NextApiRequest, NextApiResponse } from 'next'
import { supabaseAdmin } from '@/lib/supabase'

type BulkApproveRequest = {
  taskIds: string[]
  userId: string
}

type BulkApproveResponse = {
  success: boolean
  approvedCount: number
  failedIds: string[]
  message: string
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse<BulkApproveResponse | { error: string }>
) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  try {
    const { taskIds, userId }: BulkApproveRequest = req.body

    if (!taskIds || !Array.isArray(taskIds) || taskIds.length === 0) {
      return res.status(400).json({ error: 'Invalid taskIds array' })
    }

    if (!userId) {
      return res.status(400).json({ error: 'Missing userId' })
    }

    const now = new Date()
    const endOfDay = new Date(now)
    endOfDay.setHours(17, 0, 0, 0)

    // Bulk update all tasks to approved status
    const { data, error } = await supabaseAdmin
      .from('tasks')
      .update({
        status: 'approved',
        approved_at: now.toISOString(),
        scheduled_for: endOfDay.toISOString(), // Default to end of day
        updated_at: now.toISOString()
      })
      .in('id', taskIds)
      .eq('user_id', userId)
      .eq('status', 'pending') // Only update pending tasks
      .select('id')

    if (error) {
      console.error('Database error:', error)
      return res.status(500).json({ error: 'Failed to bulk approve tasks' })
    }

    const approvedIds = (data || []).map(task => task.id)
    const failedIds = taskIds.filter(id => !approvedIds.includes(id))

    res.status(200).json({
      success: true,
      approvedCount: approvedIds.length,
      failedIds,
      message: `Successfully approved ${approvedIds.length} tasks`
    })

  } catch (error) {
    console.error('Error bulk approving tasks:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
}