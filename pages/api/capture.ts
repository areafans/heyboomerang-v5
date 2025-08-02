import type { NextApiRequest, NextApiResponse } from 'next'

type CaptureRequest = {
  transcription: string
  userId: string
  timestamp: string
}

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
}

type CaptureResponse = {
  success: boolean
  tasksGenerated: Task[]
  message: string
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse<CaptureResponse | { error: string }>
) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  try {
    const { transcription, userId, timestamp }: CaptureRequest = req.body

    if (!transcription || !userId) {
      return res.status(400).json({ error: 'Missing required fields' })
    }

    // TODO: Replace with actual OpenAI integration
    // For now, return mock tasks based on transcription content
    const mockTasks: Task[] = [
      {
        id: `task_${Date.now()}_1`,
        type: 'follow_up',
        contactName: 'John Smith',
        contactPhone: '+1234567890',
        message: `Hi John, thanks for our conversation today about ${transcription.toLowerCase()}. I'll follow up with you soon with next steps.`,
        timing: 'end_of_day',
        status: 'pending',
        createdAt: new Date().toISOString()
      }
    ]

    res.status(200).json({
      success: true,
      tasksGenerated: mockTasks,
      message: `Generated ${mockTasks.length} tasks from transcription`
    })

  } catch (error) {
    console.error('Capture processing error:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
}