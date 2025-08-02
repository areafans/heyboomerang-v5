import type { NextApiRequest, NextApiResponse } from 'next'
import { seedDemoData } from '@/lib/demo-data'

type SeedResponse = {
  success: boolean
  message: string
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse<SeedResponse | { error: string }>
) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  // Only allow in development/staging environments, or if explicitly enabled
  if (process.env.NODE_ENV === 'production' && !process.env.ALLOW_DEMO_SEEDING) {
    return res.status(403).json({ error: 'Demo seeding not allowed in production' })
  }

  try {
    const success = await seedDemoData()
    
    if (success) {
      res.status(200).json({
        success: true,
        message: 'Demo data seeded successfully. Test user: mike@mikesconstruction.com'
      })
    } else {
      res.status(500).json({ error: 'Failed to seed demo data' })
    }

  } catch (error) {
    console.error('Demo seed error:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
}