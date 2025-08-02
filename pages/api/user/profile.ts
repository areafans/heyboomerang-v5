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
      // Get user profile
      const { data: userProfile, error } = await supabaseAdmin
        .from('users')
        .select('*')
        .eq('id', authUser.id)
        .single()

      if (error) {
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