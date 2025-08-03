import type { NextApiRequest, NextApiResponse } from 'next'
import { supabaseAdmin } from '@/lib/supabase'

type UpdateTaskRequest = {
  status: 'approved' | 'skipped'
  contactPhone?: string
  contactEmail?: string
  message?: string
  timing?: 'immediate' | 'end_of_day' | 'tomorrow' | 'next_week'
}

type TaskResponse = {
  success: boolean
  message: string
  task?: any
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
  res: NextApiResponse<TaskResponse | { error: string }>
) {
  const { id } = req.query

  if (!id || typeof id !== 'string') {
    return res.status(400).json({ error: 'Invalid task ID' })
  }

  if (req.method === 'PUT') {
    try {
      // Get authenticated user
      const authUser = await getUserFromAuth(req)
      if (!authUser) {
        return res.status(401).json({ error: 'Unauthorized' })
      }

      const { status, contactPhone, contactEmail, message, timing }: UpdateTaskRequest = req.body

      if (!status || !['approved', 'skipped'].includes(status)) {
        return res.status(400).json({ error: 'Invalid status' })
      }

      console.log(`📝 Updating task ${id} to status: ${status} for user: ${authUser.id}`)

      // Build update object
      const updateData: any = {
        status,
        updated_at: new Date().toISOString()
      }

      if (status === 'approved') {
        updateData.approved_at = new Date().toISOString()
        
        // Update contact details if provided
        if (contactPhone) updateData.contact_phone = contactPhone
        if (contactEmail) updateData.contact_email = contactEmail
        if (message) updateData.message = message
        if (timing) updateData.timing = timing

        // Set scheduled time based on timing
        const now = new Date()
        switch (timing) {
          case 'immediate':
            updateData.scheduled_for = now.toISOString()
            break
          case 'end_of_day':
            const endOfDay = new Date(now)
            endOfDay.setHours(17, 0, 0, 0)
            updateData.scheduled_for = endOfDay.toISOString()
            break
          case 'tomorrow':
            const tomorrow = new Date(now)
            tomorrow.setDate(tomorrow.getDate() + 1)
            tomorrow.setHours(9, 0, 0, 0)
            updateData.scheduled_for = tomorrow.toISOString()
            break
          case 'next_week':
            const nextWeek = new Date(now)
            nextWeek.setDate(nextWeek.getDate() + 7)
            nextWeek.setHours(9, 0, 0, 0)
            updateData.scheduled_for = nextWeek.toISOString()
            break
        }
      }

      // Update task in database (ensure user owns the task)
      const { data, error } = await supabaseAdmin
        .from('tasks')
        .update(updateData)
        .eq('id', id)
        .eq('user_id', authUser.id) // Security: ensure user owns the task
        .select()
        .single()

      if (error) {
        console.error('Database error:', error)
        return res.status(500).json({ error: 'Failed to update task' })
      }

      res.status(200).json({
        success: true,
        message: `Task ${status} successfully`,
        task: data
      })

    } catch (error) {
      console.error('Error updating task:', error)
      res.status(500).json({ error: 'Internal server error' })
    }
  } else {
    res.status(405).json({ error: 'Method not allowed' })
  }
}