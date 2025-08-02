import { supabaseAdmin } from './supabase'

// Pre-seeded test user
export const TEST_USER = {
  id: '550e8400-e29b-41d4-a716-446655440000', // Fixed UUID for testing
  email: 'mike@mikesconstruction.com',
  business_name: 'Mike\'s Construction',
  business_type: 'General Contracting',
  business_description: 'Full-service construction and renovation company specializing in home renovations, kitchen remodels, and custom builds.',
  phone_number: '+15551234567',
  timezone: 'America/New_York',
  subscription_status: 'trial',
  trial_ends_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString()
}

// Demo contacts
export const DEMO_CONTACTS = [
  {
    user_id: TEST_USER.id,
    name: 'Sarah Johnson',
    phone_number: '+15551234567',
    email: 'sarah@example.com',
    relationship: 'client',
    notes: 'Kitchen renovation project - budget $25k'
  },
  {
    user_id: TEST_USER.id,
    name: 'Mike Davis',
    phone_number: '+15559876543',
    relationship: 'prospect', 
    notes: 'Interested in deck project for spring'
  },
  {
    user_id: TEST_USER.id,
    name: 'Lisa Chen',
    phone_number: '+15555555555',
    email: 'lisa.chen@email.com',
    relationship: 'client',
    notes: 'Bathroom remodel completed - potential referral source'
  },
  {
    user_id: TEST_USER.id,
    name: 'Robert Wilson',
    phone_number: '+15557778888',
    relationship: 'vendor',
    notes: 'Drywall supplier - good pricing and reliability'
  }
]

// Demo voice captures
export const DEMO_CAPTURES = [
  {
    user_id: TEST_USER.id,
    transcription: 'Call Sarah about kitchen estimate tomorrow morning. She wants to increase the budget to include new appliances.',
    processing_status: 'completed',
    captured_at: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(), // 2 hours ago
    processed_at: new Date(Date.now() - 2 * 60 * 60 * 1000 + 30000).toISOString()
  },
  {
    user_id: TEST_USER.id,
    transcription: 'Remind Mike Davis about deck project timeline. Spring booking is filling up fast.',
    processing_status: 'completed',
    captured_at: new Date(Date.now() - 4 * 60 * 60 * 1000).toISOString(), // 4 hours ago
    processed_at: new Date(Date.now() - 4 * 60 * 60 * 1000 + 30000).toISOString()
  },
  {
    user_id: TEST_USER.id,
    transcription: 'Follow up with Lisa for referrals. She loved the bathroom work and mentioned her neighbor might need help.',
    processing_status: 'completed',
    captured_at: new Date(Date.now() - 6 * 60 * 60 * 1000).toISOString(), // 6 hours ago
    processed_at: new Date(Date.now() - 6 * 60 * 60 * 1000 + 30000).toISOString()
  },
  {
    user_id: TEST_USER.id,
    transcription: 'Order drywall from Robert for the Johnson kitchen project. Need delivery by Thursday.',
    processing_status: 'completed',
    captured_at: new Date(Date.now() - 8 * 60 * 60 * 1000).toISOString(), // 8 hours ago
    processed_at: new Date(Date.now() - 8 * 60 * 60 * 1000 + 30000).toISOString()
  }
]

// Demo tasks (generated from captures)
export const DEMO_TASKS = [
  {
    user_id: TEST_USER.id,
    contact_name: 'Sarah Johnson',
    contact_phone: '+15551234567',
    contact_email: 'sarah@example.com',
    task_type: 'follow_up',
    message: 'Hi Sarah! Thanks for our conversation about expanding the kitchen project budget. I\'ll prepare a revised estimate including the new appliances and send it over tomorrow morning. Looking forward to creating your dream kitchen!',
    timing: 'tomorrow',
    status: 'pending',
    scheduled_for: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(), // Tomorrow 9 AM
    expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString()
  },
  {
    user_id: TEST_USER.id,
    contact_name: 'Mike Davis',
    contact_phone: '+15559876543',
    task_type: 'reminder',
    message: 'Hi Mike! Just a friendly reminder about your deck project timeline. Spring bookings are filling up quickly, so let\'s lock in your dates soon. When would be a good time to discuss the project details?',
    timing: 'end_of_day',
    status: 'pending',
    scheduled_for: new Date().setHours(17, 0, 0, 0), // Today 5 PM
    expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString()
  },
  {
    user_id: TEST_USER.id,  
    contact_name: 'Lisa Chen',
    contact_phone: '+15555555555',
    contact_email: 'lisa.chen@email.com',
    task_type: 'campaign',
    message: 'Hi Lisa! Hope you\'re still loving your new bathroom! If you know anyone else who might need renovation work, I\'d really appreciate the referral. Thanks for being such a great customer to work with.',
    timing: 'next_week',  
    status: 'pending',
    scheduled_for: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(), // Next week
    expires_at: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000).toISOString()
  }
]

// Function to create test user and seed demo data
export async function seedDemoData() {
  try {
    console.log('🌱 Seeding demo data...')
    
    // 1. Create test user (or update if exists)
    const { error: userError } = await supabaseAdmin
      .from('users')
      .upsert({
        ...TEST_USER,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      })
    
    if (userError) {
      console.error('Error creating test user:', userError)
      return false
    }
    
    // 2. Create demo contacts
    const { error: contactsError } = await supabaseAdmin
      .from('contacts')
      .upsert(DEMO_CONTACTS.map(contact => ({
        ...contact,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      })))
    
    if (contactsError) {
      console.error('Error creating demo contacts:', contactsError)
      return false
    }
    
    // 3. Create demo captures
    const { data: capturesData, error: capturesError } = await supabaseAdmin
      .from('captures')
      .upsert(DEMO_CAPTURES.map(capture => ({
        ...capture,
        created_at: capture.captured_at
      })))
      .select()
    
    if (capturesError) {
      console.error('Error creating demo captures:', capturesError)
      return false
    }
    
    // 4. Create demo tasks (link to captures if available)
    const tasksWithCaptureIds = DEMO_TASKS.map((task, index) => ({
      ...task,
      capture_id: capturesData?.[index]?.id || null,
      created_at: new Date(Date.now() - (index + 1) * 60 * 60 * 1000).toISOString() // Stagger creation times
    }))
    
    const { error: tasksError } = await supabaseAdmin
      .from('tasks')
      .upsert(tasksWithCaptureIds)
    
    if (tasksError) {
      console.error('Error creating demo tasks:', tasksError)
      return false
    }
    
    console.log('✅ Demo data seeded successfully!')
    return true
    
  } catch (error) {
    console.error('Error seeding demo data:', error)
    return false
  }
}

// Function to remove demo data for a user
export async function removeDemoData(userId: string) {
  try {
    console.log(`🧹 Removing demo data for user: ${userId}`)
    
    // Delete in reverse order of dependencies
    await supabaseAdmin.from('messages').delete().eq('user_id', userId)
    await supabaseAdmin.from('tasks').delete().eq('user_id', userId)
    await supabaseAdmin.from('captures').delete().eq('user_id', userId)
    await supabaseAdmin.from('contacts').delete().eq('user_id', userId)
    await supabaseAdmin.from('user_context').delete().eq('user_id', userId)
    await supabaseAdmin.from('contact_insights').delete().eq('user_id', userId)
    
    console.log('✅ Demo data removed successfully!')
    return true
    
  } catch (error) {
    console.error('Error removing demo data:', error)
    return false
  }
}