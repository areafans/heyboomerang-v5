import type { NextApiRequest, NextApiResponse } from 'next'
import { supabaseAdmin } from '@/lib/supabase'
import OpenAI from 'openai'

type CaptureRequest = {
  transcription: string
  duration?: number
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

// Initialize OpenAI client
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
})

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
  res: NextApiResponse<CaptureResponse | { error: string }>
) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  try {
    // Get authenticated user
    const authUser = await getUserFromAuth(req)
    if (!authUser) {
      return res.status(401).json({ error: 'Unauthorized' })
    }

    const { transcription, duration }: CaptureRequest = req.body

    if (!transcription || transcription.trim().length === 0) {
      return res.status(400).json({ error: 'Transcription is required' })
    }

    console.log('🎤 Processing voice capture for user:', authUser.id)
    console.log('📝 Transcription:', transcription.substring(0, 100) + '...')

    // 1. Store the capture in database
    const { data: captureData, error: captureError } = await supabaseAdmin
      .from('captures')
      .insert({
        user_id: authUser.id,
        transcription: transcription,
        audio_duration_seconds: duration || 0,
        captured_at: new Date().toISOString(),
        processing_status: 'processing'
      })
      .select()
      .single()

    if (captureError) {
      console.error('Failed to store capture:', captureError)
      return res.status(500).json({ error: 'Failed to store capture' })
    }

    console.log('💾 Capture stored with ID:', captureData.id)

    // 2. Get user's business context for AI processing
    const { data: userData } = await supabaseAdmin
      .from('users')
      .select('business_name, business_type, business_description')
      .eq('id', authUser.id)
      .single()

    const businessContext = userData ? 
      `Business: ${userData.business_name} (${userData.business_type}). ${userData.business_description || ''}` :
      'Small service business'

    // 3. Use OpenAI to generate tasks from transcription
    const systemPrompt = `You are an AI assistant for ${businessContext}. 

Your job is to analyze voice transcriptions from the business owner and generate actionable communication tasks.

Rules:
1. Extract contact names, phone numbers, and emails when mentioned
2. Determine if this requires follow-up communication (follow_up), a reminder to yourself (reminder), or a marketing campaign (campaign)
3. Generate professional, personalized messages that match the business context
4. Choose appropriate timing: immediate, end_of_day, tomorrow, or next_week
5. Only generate tasks that make business sense - skip casual conversations

Return valid JSON array of tasks in this exact format:
[{
  "type": "follow_up" | "reminder" | "campaign",
  "contactName": "Name from transcription or 'Unknown Contact'",
  "contactPhone": "phone if mentioned, null otherwise",
  "contactEmail": "email if mentioned, null otherwise", 
  "message": "Professional message text",
  "timing": "immediate" | "end_of_day" | "tomorrow" | "next_week"
}]

If no actionable tasks can be extracted, return an empty array []`

    try {
      const completion = await openai.chat.completions.create({
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: systemPrompt },
          { role: "user", content: `Transcription: "${transcription}"` }
        ],
        temperature: 0.7,
        max_tokens: 1000,
      })

      const aiResponse = completion.choices[0]?.message?.content || '[]'
      console.log('🤖 OpenAI response:', aiResponse)

      // Parse AI response
      let aiTasks: any[] = []
      try {
        aiTasks = JSON.parse(aiResponse)
      } catch (parseError) {
        console.error('Failed to parse AI response:', parseError)
        console.log('Raw AI response:', aiResponse)
        // Fallback to empty array if parsing fails
        aiTasks = []
      }

      if (!Array.isArray(aiTasks)) {
        console.error('AI response is not an array:', aiTasks)
        aiTasks = []
      }

      // 4. Store generated tasks in database
      const tasks: Task[] = []
      
      for (const aiTask of aiTasks) {
        if (!aiTask.contactName || !aiTask.message || !aiTask.type || !aiTask.timing) {
          console.warn('Skipping incomplete AI task:', aiTask)
          continue
        }

        // Calculate scheduled_for based on timing
        const now = new Date()
        let scheduledFor = new Date()
        
        switch (aiTask.timing) {
          case 'immediate':
            scheduledFor = now
            break
          case 'end_of_day':
            scheduledFor.setHours(17, 0, 0, 0) // 5 PM today
            if (scheduledFor <= now) {
              scheduledFor.setDate(scheduledFor.getDate() + 1) // Tomorrow if past 5 PM
            }
            break
          case 'tomorrow':
            scheduledFor.setDate(now.getDate() + 1)
            scheduledFor.setHours(9, 0, 0, 0) // 9 AM tomorrow
            break
          case 'next_week':
            scheduledFor.setDate(now.getDate() + 7)
            scheduledFor.setHours(9, 0, 0, 0) // 9 AM next week
            break
          default:
            scheduledFor = now
        }

        const { data: taskData, error: taskError } = await supabaseAdmin
          .from('tasks')
          .insert({
            user_id: authUser.id,
            capture_id: captureData.id,
            contact_name: aiTask.contactName,
            contact_phone: aiTask.contactPhone || null,
            contact_email: aiTask.contactEmail || null,
            task_type: aiTask.type,
            message: aiTask.message,
            timing: aiTask.timing,
            scheduled_for: scheduledFor.toISOString(),
            status: 'pending',
            delivery_method: 'sms', // Default to SMS, can be changed in review
            expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString() // 7 days
          })
          .select()
          .single()

        if (taskError) {
          console.error('Failed to store task:', taskError)
          continue
        }

        // Add to response
        tasks.push({
          id: taskData.id,
          type: taskData.task_type as Task['type'],
          contactName: taskData.contact_name,
          contactPhone: taskData.contact_phone || undefined,
          contactEmail: taskData.contact_email || undefined,
          message: taskData.message,
          timing: taskData.timing as Task['timing'],
          status: taskData.status as Task['status'],
          createdAt: taskData.created_at
        })
      }

      // 5. Update capture status to completed
      await supabaseAdmin
        .from('captures')
        .update({ 
          processing_status: 'completed',
          processed_at: new Date().toISOString()
        })
        .eq('id', captureData.id)

      console.log(`✅ Generated ${tasks.length} tasks from voice capture`)

      res.status(200).json({
        success: true,
        tasksGenerated: tasks,
        message: `Generated ${tasks.length} tasks from transcription`
      })

    } catch (openaiError) {
      console.error('OpenAI processing error:', openaiError)
      
      // Update capture status to failed
      await supabaseAdmin
        .from('captures')
        .update({ processing_status: 'failed' })
        .eq('id', captureData.id)
      
      return res.status(500).json({ error: 'AI processing failed' })
    }

  } catch (error) {
    console.error('Capture processing error:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
}