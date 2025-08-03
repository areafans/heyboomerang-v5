import type { NextApiRequest, NextApiResponse } from 'next'
import { supabaseAdmin } from '@/lib/supabase'

type UpdateProfileRequest = {
  businessName?: string
  businessType?: string
  businessDescription?: string
  phoneNumber?: string
  timezone?: string
}

type UserProfile = {
  id: string
  email: string
  businessName?: string
  businessType?: string
  businessDescription?: string
  phoneNumber?: string
  timezone?: string
  subscriptionStatus: string
  trialEndsAt?: string
  createdAt: string
  updatedAt: string
}

type ProfileResponse = {
  success: boolean
  user?: UserProfile
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
  res: NextApiResponse<ProfileResponse | { error: string }>
) {
  try {
    // Get authenticated user
    const authUser = await getUserFromAuth(req)
    if (!authUser) {
      return res.status(401).json({ error: 'Unauthorized' })
    }

    if (req.method === 'GET') {
      // Get user profile, create if doesn't exist
      let { data: userProfile, error } = await supabaseAdmin
        .from('users')
        .select('*')
        .eq('id', authUser.id)
        .single()

      // If user doesn't exist, create them
      if (error && error.code === 'PGRST116') { // Not found
        console.log('Creating new user profile for:', authUser.id, authUser.email)
        
        const { data: newUser, error: createError } = await supabaseAdmin
          .from('users')
          .insert({
            id: authUser.id,
            email: authUser.email,
            business_name: 'My Business', // Temporary default, will be updated during onboarding
            business_type: 'Service Business', // Temporary default, will be updated during onboarding
            business_description: null,
            phone_number: null,
            timezone: 'America/New_York',
            subscription_status: 'trial',
            trial_ends_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString()
          })
          .select()
          .single()

        if (createError) {
          console.error('Profile creation error:', createError)
          console.error('Error details:', JSON.stringify(createError, null, 2))
          return res.status(500).json({ 
            error: `Failed to create user profile: ${createError.message}`
          })
        }
        
        console.log('User profile created successfully:', newUser)
        userProfile = newUser
      } else if (error) {
        console.error('Profile lookup error:', error)
        return res.status(500).json({ error: 'Failed to get user profile' })
      }

      const profile: UserProfile = {
        id: userProfile.id,
        email: userProfile.email,
        businessName: userProfile.business_name,
        businessType: userProfile.business_type,
        businessDescription: userProfile.business_description,
        phoneNumber: userProfile.phone_number,
        timezone: userProfile.timezone,
        subscriptionStatus: userProfile.subscription_status,
        trialEndsAt: userProfile.trial_ends_at,
        createdAt: userProfile.created_at,
        updatedAt: userProfile.updated_at
      }

      res.status(200).json({
        success: true,
        user: profile,
        message: 'Profile retrieved successfully'
      })

    } else if (req.method === 'POST') {
      // Create new user profile
      const { email, businessName, businessType, businessDescription } = req.body

      if (!email || !businessName) {
        return res.status(400).json({ error: 'Email and business name are required' })
      }

      const { data: newUser, error: createError } = await supabaseAdmin
        .from('users')
        .insert({
          id: authUser.id,
          email: email.toLowerCase().trim(),
          business_name: businessName,
          business_type: businessType || 'Service Business',
          business_description: businessDescription || '',
          phone_number: null,
          timezone: 'America/New_York',
          subscription_status: 'trial',
          trial_ends_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        })
        .select()
        .single()

      if (createError) {
        console.error('User creation error:', createError)
        return res.status(500).json({ error: 'Failed to create user profile' })
      }

      const profile: UserProfile = {
        id: newUser.id,
        email: newUser.email,
        businessName: newUser.business_name,
        businessType: newUser.business_type,
        businessDescription: newUser.business_description,
        phoneNumber: newUser.phone_number,
        timezone: newUser.timezone,
        subscriptionStatus: newUser.subscription_status,
        trialEndsAt: newUser.trial_ends_at,
        createdAt: newUser.created_at,
        updatedAt: newUser.updated_at
      }

      res.status(201).json({
        success: true,
        user: profile,
        message: 'User profile created successfully'
      })

    } else if (req.method === 'PUT') {
      // Update user profile
      const updateData: UpdateProfileRequest = req.body

      const { data: updatedProfile, error } = await supabaseAdmin
        .from('users')
        .update({
          business_name: updateData.businessName,
          business_type: updateData.businessType,
          business_description: updateData.businessDescription,
          phone_number: updateData.phoneNumber,
          timezone: updateData.timezone,
          updated_at: new Date().toISOString()
        })
        .eq('id', authUser.id)
        .select()
        .single()

      if (error) {
        console.error('Profile update error:', error)
        return res.status(500).json({ error: 'Failed to update user profile' })
      }

      const profile: UserProfile = {
        id: updatedProfile.id,
        email: updatedProfile.email,
        businessName: updatedProfile.business_name,
        businessType: updatedProfile.business_type,
        businessDescription: updatedProfile.business_description,
        phoneNumber: updatedProfile.phone_number,
        timezone: updatedProfile.timezone,
        subscriptionStatus: updatedProfile.subscription_status,
        trialEndsAt: updatedProfile.trial_ends_at,
        createdAt: updatedProfile.created_at,
        updatedAt: updatedProfile.updated_at
      }

      res.status(200).json({
        success: true,
        user: profile,
        message: 'Profile updated successfully'
      })

    } else {
      res.status(405).json({ error: 'Method not allowed' })
    }

  } catch (error) {
    console.error('Profile handler error:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
}