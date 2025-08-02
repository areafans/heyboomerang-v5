import type { NextApiRequest, NextApiResponse } from 'next'
import { supabaseAdmin } from '@/lib/supabase'

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  try {
    const { code, error: authError } = req.query

    if (authError) {
      console.error('Auth callback error:', authError)
      return res.redirect('/auth/error?message=' + encodeURIComponent(authError as string))
    }

    if (!code) {
      return res.redirect('/auth/error?message=' + encodeURIComponent('No authorization code provided'))
    }

    // Exchange code for session
    const { data, error } = await supabaseAdmin.auth.exchangeCodeForSession(code as string)

    if (error) {
      console.error('Code exchange error:', error)
      return res.redirect('/auth/error?message=' + encodeURIComponent(error.message))
    }

    if (!data.user) {
      return res.redirect('/auth/error?message=' + encodeURIComponent('No user found'))
    }

    // Check if user exists in our users table, create if not
    const { data: existingUser, error: userError } = await supabaseAdmin
      .from('users')
      .select('*')
      .eq('id', data.user.id)
      .single()

    if (userError && userError.code !== 'PGRST116') { // PGRST116 = not found
      console.error('User lookup error:', userError)
      return res.redirect('/auth/error?message=' + encodeURIComponent('Database error'))
    }

    // If user doesn't exist in our users table, create them
    if (!existingUser) {
      const { error: createError } = await supabaseAdmin
        .from('users')
        .insert({
          id: data.user.id,
          email: data.user.email,
          business_name: null,
          business_type: null,
          business_description: null,
          subscription_status: 'trial',
          trial_ends_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(), // 7 days
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        })

      if (createError) {
        console.error('User creation error:', createError)
        return res.redirect('/auth/error?message=' + encodeURIComponent('Failed to create user profile'))
      }
    }

    // Create session token for iOS app (you'll need this for API authentication)
    const sessionToken = data.session?.access_token

    // For now, redirect to a success page with the token
    // In production, this would be handled by your iOS app's URL scheme
    const successUrl = `/auth/success?token=${sessionToken}&user_id=${data.user.id}`
    
    res.redirect(successUrl)

  } catch (error) {
    console.error('Callback handler error:', error)
    res.redirect('/auth/error?message=' + encodeURIComponent('Internal server error'))
  }
}