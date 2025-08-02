// Simple database connection test
// Run with: node test-db.js

const { createClient } = require('@supabase/supabase-js')

const supabaseUrl = 'https://vzcqwvxzkorejjrvdylh.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ6Y3F3dnh6a29yZWpqcnZkeWxoIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NDE1NjQ5NiwiZXhwIjoyMDY5NzMyNDk2fQ.4mjK1JDnu6klOdsS7dEfk76vRPci5V9HV-a0M7tWRhI'

const supabase = createClient(supabaseUrl, supabaseKey)

async function testConnection() {
  console.log('🔍 Testing Supabase connection...')
  
  try {
    // Test 1: Basic connection
    const { data, error } = await supabase.from('users').select('count').limit(1)
    
    if (error) {
      console.log('❌ Database connection failed:', error.message)
      return
    }
    
    console.log('✅ Database connection successful!')
    
    // Test 2: Check if tables exist
    const tables = ['users', 'contacts', 'captures', 'tasks', 'messages']
    
    for (const table of tables) {
      const { error: tableError } = await supabase.from(table).select('count').limit(1)
      if (tableError) {
        console.log(`❌ Table '${table}' not found:`, tableError.message)
      } else {
        console.log(`✅ Table '${table}' exists`)
      }
    }
    
    console.log('\n🎯 Database is ready for use!')
    
  } catch (err) {
    console.log('❌ Connection test failed:', err.message)
  }
}

testConnection()