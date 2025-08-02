import type { NextApiRequest, NextApiResponse } from 'next'
import { supabaseAdmin } from '@/lib/supabase'

type SigninRequest = {
  email: string
  redirectTo?: string
}

type SigninResponse = {
  success: boolean
  message: string
  checkEmail?: boolean
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse<SigninResponse | { error: string }>
) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  try {
    const { email, redirectTo }: SigninRequest = req.body

    if (!email) {
      return res.status(400).json({ error: 'Email is required' })
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(email)) {
      return res.status(400).json({ error: 'Invalid email format' })
    }

    // Use Supabase Auth to send magic link
    const { error } = await supabaseAdmin.auth.signInWithOtp({
      email: email.toLowerCase().trim(),
      options: {
        emailRedirectTo: redirectTo || `${process.env.NEXT_PUBLIC_SITE_URL || 'http://localhost:3000'}/auth/callback`,
        shouldCreateUser: true, // Create user if doesn't exist
      }
    })

    if (error) {
      console.error('Magic link send error:', error)
      return res.status(500).json({ error: 'Failed to send magic link' })
    }

    res.status(200).json({
      success: true,
      message: 'Magic link sent! Please check your email.',
      checkEmail: true
    })

  } catch (error) {
    console.error('Signin error:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
}