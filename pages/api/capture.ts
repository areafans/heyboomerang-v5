import type { NextApiRequest, NextApiResponse } from 'next'
import { supabaseAdmin } from '@/lib/supabase'
import OpenAI from 'openai'

type CaptureRequest = {
  transcription: string
  duration?: number
}

type Task = {
  id: string
  userId: string
  captureId: string
  type: 'follow_up_sms' | 'reminder' | 'reminder_call' | 'campaign' | 'contact_crud' | 'email_send_reply'
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

// Helper function to convert OpenAI function calls to standardized task format
function convertFunctionCallToTask(functionName: string, args: any, userId: string, captureId: string) {
  const timing = args.timing || 'tomorrow'
  
  switch (functionName) {
    case 'create_contact':
      return {
        task_type: 'contact_crud', // Match iOS TaskType enum
        contact_name: args.name,
        contact_phone: args.phone?.trim() || null,
        contact_email: args.email?.trim() || null,
        message: `Create new ${args.type} contact: ${args.name}${args.notes ? `. Notes: ${args.notes}` : ''}`,
        timing,
        delivery_method: 'internal' // Internal app action
      }
      
    case 'send_sms':
      return {
        task_type: 'follow_up_sms', // Match iOS TaskType enum
        contact_name: args.contactName,
        contact_phone: null, // Will be resolved during task execution
        contact_email: null,
        message: args.message,
        timing,
        delivery_method: 'sms'
      }
      
    case 'send_email':
      return {
        task_type: 'email_send_reply', // Match iOS TaskType enum
        contact_name: args.contactName,
        contact_phone: null,
        contact_email: null, // Will be resolved during task execution
        message: `Subject: ${args.subject}\n\n${args.message}`,
        timing,
        delivery_method: 'email'
      }
      
    case 'create_reminder':
      return {
        task_type: 'reminder', // General reminder, not specifically a call
        contact_name: 'Business Owner',
        contact_phone: null,
        contact_email: null,
        message: args.task,
        timing,
        delivery_method: 'internal'
      }
      
    case 'make_phone_call':
      return {
        task_type: 'reminder_call', // This is actually a call reminder
        contact_name: args.contactName,
        contact_phone: null, // Will be resolved during task execution
        contact_email: null,
        message: `Call about: ${args.purpose}`,
        timing,
        delivery_method: 'phone'
      }
      
    case 'create_note':
      return {
        task_type: 'contact_crud', // Use existing enum value for notes
        contact_name: 'Business Owner',
        contact_phone: null,
        contact_email: null,
        message: `Note: ${args.title} - ${args.content}`,
        timing: 'immediate',
        delivery_method: 'internal'
      }
      
    default:
      console.warn(`Unknown function: ${functionName}`)
      return null
  }
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

    // 3. Use OpenAI function calling to generate business tasks from transcription
    const systemPrompt = `You are an AI assistant for ${businessContext}. 

Analyze voice transcriptions and call the appropriate functions to generate business tasks for user review.

AVAILABLE FUNCTIONS:
- create_contact: For "Create contact for [name]", "Add [name] as customer", etc.
- send_sms: For "Text [name] about [topic]", "Send SMS to [name]", etc. 
- send_email: For "Email [name] about [topic]", "Send email to [name]", etc.
- create_reminder: For "Remind me to [task]", "Don't forget to [task]", etc.
- make_phone_call: For "Call [name] about [topic]", "Phone [name]", etc.
- create_note: For "Note that [info]", "Remember [info]", etc.

RULES:
1. ALWAYS call at least one function for business-related transcriptions
2. Extract contact names, phone numbers, emails when mentioned
3. Choose appropriate timing: immediate (urgent), end_of_day (same day), tomorrow (next day), next_week (later)
4. Create clear, professional messages for communications
5. Use "customer" as default contact type unless specified otherwise

EXAMPLES:
- "Remind me to order drywall" → create_reminder(task: "Order drywall", timing: "tomorrow")
- "Text John about his appointment tomorrow" → send_sms(contactName: "John", message: "...", timing: "end_of_day")
- "Create a contact for Mike Smith, he's a new customer" → create_contact(name: "Mike Smith", type: "customer")`

    const tools = [
      {
        type: "function" as const,
        function: {
          name: "create_contact",
          description: "Create a new contact (customer, lead, vendor, etc.)",
          parameters: {
            type: "object",
            properties: {
              name: { type: "string", description: "Full name of the contact" },
              phone: { type: "string", description: "Phone number if mentioned, empty string if not" },
              email: { type: "string", description: "Email address if mentioned, empty string if not" },
              type: { 
                type: "string", 
                enum: ["customer", "lead", "vendor", "partner"],
                description: "Type of contact"
              },
              notes: { type: "string", description: "Any additional details mentioned" }
            },
            required: ["name", "type"],
            additionalProperties: false
          }
        }
      },
      {
        type: "function" as const,
        function: {
          name: "send_sms",
          description: "Send SMS message to a contact",
          parameters: {
            type: "object",
            properties: {
              contactName: { type: "string", description: "Name of recipient" },
              message: { type: "string", description: "SMS message content" },
              timing: {
                type: "string",
                enum: ["immediate", "end_of_day", "tomorrow", "next_week"],
                description: "When to send the message"
              }
            },
            required: ["contactName", "message", "timing"],
            additionalProperties: false
          }
        }
      },
      {
        type: "function" as const,
        function: {
          name: "send_email", 
          description: "Send email message to a contact",
          parameters: {
            type: "object",
            properties: {
              contactName: { type: "string", description: "Name of recipient" },
              subject: { type: "string", description: "Email subject line" },
              message: { type: "string", description: "Email message content" },
              timing: {
                type: "string", 
                enum: ["immediate", "end_of_day", "tomorrow", "next_week"],
                description: "When to send the email"
              }
            },
            required: ["contactName", "subject", "message", "timing"],
            additionalProperties: false
          }
        }
      },
      {
        type: "function" as const,
        function: {
          name: "create_reminder",
          description: "Create a personal reminder/todo for the business owner",
          parameters: {
            type: "object",
            properties: {
              task: { type: "string", description: "What needs to be done" },
              timing: {
                type: "string",
                enum: ["immediate", "end_of_day", "tomorrow", "next_week"],
                description: "When to be reminded"
              },
              priority: {
                type: "string",
                enum: ["low", "medium", "high"],
                description: "Priority level of the reminder"
              }
            },
            required: ["task", "timing"],
            additionalProperties: false
          }
        }
      },
      {
        type: "function" as const,
        function: {
          name: "make_phone_call",
          description: "Schedule/reminder to make a phone call to a contact", 
          parameters: {
            type: "object",
            properties: {
              contactName: { type: "string", description: "Name of person to call" },
              purpose: { type: "string", description: "Reason for the call" },
              timing: {
                type: "string",
                enum: ["immediate", "end_of_day", "tomorrow", "next_week"], 
                description: "When to make the call"
              }
            },
            required: ["contactName", "purpose", "timing"],
            additionalProperties: false
          }
        }
      },
      {
        type: "function" as const,
        function: {
          name: "create_note",
          description: "Create a business note for future reference",
          parameters: {
            type: "object",
            properties: {
              title: { type: "string", description: "Brief title for the note" },
              content: { type: "string", description: "Note content" },
              tags: { 
                type: "array", 
                items: { type: "string" },
                description: "Tags for categorizing the note"
              }
            },
            required: ["title", "content"],
            additionalProperties: false
          }
        }
      }
    ]

    try {
      console.log('🚀 Making OpenAI API call with transcription:', transcription)
      console.log('🔧 Tools schema:', JSON.stringify(tools, null, 2))
      
      const completion = await openai.chat.completions.create({
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: systemPrompt },
          { role: "user", content: `Transcription: "${transcription}"` }
        ],
        tools,
        tool_choice: "required", // Let AI choose which function(s) to call
        temperature: 0.7,
        max_tokens: 1000,
      })

      console.log('🤖 OpenAI completion response:', JSON.stringify(completion, null, 2))

      const toolCalls = completion.choices[0]?.message?.tool_calls || []
      if (toolCalls.length === 0) {
        console.error('❌ No tool calls returned')
        console.error('Response choices:', completion.choices)
        console.error('Message:', completion.choices[0]?.message)
        return res.status(500).json({ error: 'AI processing failed - no tool calls' })
      }

      console.log(`🛠️ Processing ${toolCalls.length} tool calls`)
      
      // 4. Process each function call and convert to database tasks
      const tasks: Task[] = []
      
      for (const toolCall of toolCalls) {
        try {
          const functionName = toolCall.function.name
          const args = JSON.parse(toolCall.function.arguments)
          
          console.log(`📞 Processing ${functionName} with args:`, args)
          
          // Convert function call to standardized task format
          const taskData = convertFunctionCallToTask(functionName, args, authUser.id, captureData.id)
          
          if (!taskData) {
            console.warn(`⚠️ Could not convert function call: ${functionName}`)
            continue
          }

          // Calculate scheduled_for based on timing
          const now = new Date()
          let scheduledFor = new Date()
          
          switch (taskData.timing) {
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

          const { data: dbTaskData, error: taskError } = await supabaseAdmin
            .from('tasks')
            .insert({
              user_id: authUser.id,
              capture_id: captureData.id,
              contact_name: taskData.contact_name,
              contact_phone: taskData.contact_phone,
              contact_email: taskData.contact_email,
              task_type: taskData.task_type,
              message: taskData.message,
              timing: taskData.timing,
              scheduled_for: scheduledFor.toISOString(),
              status: 'pending',
              delivery_method: taskData.delivery_method,
              expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString() // 7 days
            })
            .select()
            .single()

          if (taskError) {
            console.error(`❌ Failed to store ${taskData.task_type} task:`, taskError)
            console.error('Task data that failed:', taskData)
            console.error('Database error details:', taskError.message, taskError.code, taskError.details)
            continue
          }

          console.log(`✅ Created ${taskData.task_type} task:`, dbTaskData.id)

          // Add to response - match iOS AppTask structure
          tasks.push({
            id: dbTaskData.id,
            userId: authUser.id,
            captureId: captureData.id,
            type: dbTaskData.task_type as Task['type'],
            status: dbTaskData.status as Task['status'],
            contactId: dbTaskData.contact_id || undefined,
            contactName: dbTaskData.contact_name || undefined,
            message: dbTaskData.message,
            originalTranscription: transcription, // Include original voice input
            scheduledFor: dbTaskData.scheduled_for || undefined,
            createdAt: dbTaskData.created_at,
            archivedAt: undefined,
            dismissedAt: undefined
          })
          
        } catch (toolError) {
          console.error(`❌ Error processing tool call ${toolCall.function.name}:`, toolError)
          continue
        }
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

    } catch (openaiError: any) {
      console.error('❌ OpenAI processing error:', openaiError)
      console.error('Error message:', openaiError?.message)
      console.error('Error response:', openaiError?.response?.data)
      console.error('Error status:', openaiError?.response?.status)
      console.error('Full error object:', JSON.stringify(openaiError, Object.getOwnPropertyNames(openaiError), 2))
      
      // Update capture status to failed
      await supabaseAdmin
        .from('captures')
        .update({ processing_status: 'failed' })
        .eq('id', captureData.id)
      
      return res.status(500).json({ 
        error: `AI processing failed: ${openaiError?.message || 'Unknown OpenAI error'}`
      })
    }

  } catch (error) {
    console.error('Capture processing error:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
}