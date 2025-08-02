import type { NextApiRequest, NextApiResponse } from 'next'

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

    // TODO: Replace with actual database query
    // For now, return mock pending tasks
    const mockTasks: Task[] = [
      {
        id: 'task_001',
        type: 'follow_up',
        contactName: 'Sarah Johnson',
        contactPhone: '+1555123456',
        message: 'Hi Sarah, thanks for discussing the kitchen renovation today. I\'ll send over the estimate by tomorrow morning.',
        timing: 'tomorrow',
        status: 'pending',
        createdAt: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(), // 2 hours ago
        originalTranscription: 'Call Sarah about kitchen estimate tomorrow'
      },
      {
        id: 'task_002',
        type: 'reminder',
        contactName: 'Mike Davis',
        contactEmail: 'mike@example.com',
        message: 'Hi Mike, just a reminder that we\'re scheduled to start the deck project next Monday at 8 AM.',
        timing: 'end_of_day',
        status: 'pending',
        createdAt: new Date(Date.now() - 4 * 60 * 60 * 1000).toISOString(), // 4 hours ago
        originalTranscription: 'Remind Mike about deck project starting Monday'
      },
      {
        id: 'task_003',
        type: 'campaign',
        contactName: 'Lisa Chen',
        contactPhone: '+1555987654',
        contactEmail: 'lisa@example.com',
        message: 'Hi Lisa, hope you\'re enjoying your new bathroom! If you know anyone else who might need renovation work, I\'d appreciate the referral.',
        timing: 'next_week',
        status: 'pending',
        createdAt: new Date(Date.now() - 6 * 60 * 60 * 1000).toISOString(), // 6 hours ago
        originalTranscription: 'Follow up with Lisa for referrals next week'
      }
    ]

    res.status(200).json({
      success: true,
      tasks: mockTasks,
      count: mockTasks.length
    })

  } catch (error) {
    console.error('Error fetching pending tasks:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
}