import type { NextApiRequest, NextApiResponse } from 'next'
import { supabaseAdmin } from '@/lib/supabase'

type HealthResponse = {
  status: string
  timestamp: string
  environment: string
  services: {
    database: string
    openai: string
    twilio: string
    sendgrid: string
  }
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse<HealthResponse>
) {
  if (req.method !== 'GET') {
    return res.status(405).json({
      status: 'error',
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV || 'development',
      services: {
        database: 'not available',
        openai: 'not available',
        twilio: 'not available',
        sendgrid: 'not available'
      }
    })
  }

  // Test database connection
  let databaseStatus = 'not configured'
  try {
    if (process.env.SUPABASE_URL) {
      const { error } = await supabaseAdmin.from('users').select('count').limit(1)
      databaseStatus = error ? 'connection failed' : 'connected'
    }
  } catch (error) {
    databaseStatus = 'connection failed'
  }

  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    services: {
      database: databaseStatus,
      openai: process.env.OPENAI_API_KEY ? 'configured' : 'not configured',
      twilio: process.env.TWILIO_ACCOUNT_SID ? 'configured' : 'not configured',
      sendgrid: process.env.SENDGRID_API_KEY ? 'configured' : 'not configured'
    }
  })
}