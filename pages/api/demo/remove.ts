import type { NextApiRequest, NextApiResponse } from 'next'
import { removeDemoData } from '@/lib/demo-data'
import { supabaseAdmin } from '@/lib/supabase'

type RemoveResponse = {
  success: boolean
  message: string
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
  res: NextApiResponse<RemoveResponse | { error: string }>
) {
  if (req.method !== 'DELETE') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  try {
    // Get authenticated user
    const authUser = await getUserFromAuth(req)
    if (!authUser) {
      return res.status(401).json({ error: 'Unauthorized' })
    }

    const success = await removeDemoData(authUser.id)
    
    if (success) {
      res.status(200).json({
        success: true,
        message: 'Demo data removed successfully'
      })
    } else {
      res.status(500).json({ error: 'Failed to remove demo data' })
    }

  } catch (error) {
    console.error('Demo remove error:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
}