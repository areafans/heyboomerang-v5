import type { NextApiRequest, NextApiResponse } from 'next'
import { supabaseAdmin } from '@/lib/supabase'

type VerifyTokenRequest = {
  token: string
}

type VerifyTokenResponse = {
  success: boolean
  user?: {
    id: string
    email: string
    businessName?: string
    businessType?: string
    businessDescription?: string
    subscriptionStatus: string
  }
  message: string
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse<VerifyTokenResponse | { error: string }>
) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  try {
    const { token }: VerifyTokenRequest = req.body

    if (!token) {
      return res.status(400).json({ error: 'Token is required' })
    }

    // Verify the JWT token with Supabase
    const { data: authUser, error: authError } = await supabaseAdmin.auth.getUser(token)

    if (authError || !authUser.user) {
      return res.status(401).json({ error: 'Invalid or expired token' })
    }

    // Get user profile from our users table
    const { data: userProfile, error: profileError } = await supabaseAdmin
      .from('users')
      .select('*')
      .eq('id', authUser.user.id)
      .single()

    if (profileError) {
      console.error('Profile lookup error:', profileError)
      return res.status(500).json({ error: 'Failed to get user profile' })
    }

    res.status(200).json({
      success: true,
      user: {
        id: userProfile.id,
        email: userProfile.email,
        businessName: userProfile.business_name,
        businessType: userProfile.business_type,
        businessDescription: userProfile.business_description,
        subscriptionStatus: userProfile.subscription_status
      },
      message: 'Token verified successfully'
    })

  } catch (error) {
    console.error('Token verification error:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
}