import Head from 'next/head'
import { useState } from 'react'

export default function TestAuth() {
  const [email, setEmail] = useState('mike@mikesconstruction.com')
  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState('')
  const [token, setToken] = useState('')
  const [profileData, setProfileData] = useState<any>(null)

  const sendMagicLink = async () => {
    setLoading(true)
    setMessage('')
    
    try {
      const response = await fetch('/api/auth/signin', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email }),
      })
      
      const data = await response.json()
      
      if (response.ok) {
        setMessage(`✅ ${data.message}`)
      } else {
        setMessage(`❌ Error: ${data.error}`)
      }
    } catch (error) {
      setMessage('❌ Network error')
    } finally {
      setLoading(false)
    }
  }

  const verifyToken = async () => {
    if (!token) return
    
    setLoading(true)
    setMessage('')
    
    try {
      const response = await fetch('/api/auth/verify-token', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ token }),
      })
      
      const data = await response.json()
      
      if (response.ok) {
        setMessage(`✅ Token verified: ${data.user?.email}`)
      } else {
        setMessage(`❌ Error: ${data.error}`)
      }
    } catch (error) {
      setMessage('❌ Network error')
    } finally {
      setLoading(false)
    }
  }

  const getProfile = async () => {
    if (!token) return
    
    setLoading(true)
    setMessage('')
    
    try {
      const response = await fetch('/api/user/profile', {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
        },
      })
      
      const data = await response.json()
      
      if (response.ok) {
        setProfileData(data.user)
        setMessage(`✅ Profile loaded: ${data.user?.email}`)
      } else {
        setMessage(`❌ Error: ${data.error}`)
      }
    } catch (error) {
      setMessage('❌ Network error')
    } finally {
      setLoading(false)
    }
  }

  const seedDemoData = async () => {
    setLoading(true)
    setMessage('')
    
    try {
      const response = await fetch('/api/demo/seed', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
      })
      
      const data = await response.json()
      
      if (response.ok) {
        setMessage(`✅ ${data.message}`)
      } else {
        setMessage(`❌ Error: ${data.error}`)
      }
    } catch (error) {
      setMessage('❌ Network error')
    } finally {
      setLoading(false)
    }
  }

  const testPendingTasks = async () => {
    if (!token) return
    
    setLoading(true)
    setMessage('')
    
    try {
      const response = await fetch('/api/tasks/pending?userId=550e8400-e29b-41d4-a716-446655440000', {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
        },
      })
      
      const data = await response.json()
      
      if (response.ok) {
        setMessage(`✅ Found ${data.tasks?.length || 0} pending tasks`)
      } else {
        setMessage(`❌ Error: ${data.error}`)
      }
    } catch (error) {
      setMessage('❌ Network error')
    } finally {
      setLoading(false)
    }
  }

  return (
    <>
      <Head>
        <title>Test Magic Link Auth - Boomerang</title>
      </Head>
      <main style={{ padding: '2rem', fontFamily: 'system-ui, sans-serif', maxWidth: '800px', margin: '0 auto' }}>
        <h1>🧪 Test Magic Link Authentication</h1>
        
        {/* Step 1: Seed Demo Data */}
        <div style={{ marginBottom: '2rem', padding: '1rem', border: '1px solid #ddd', borderRadius: '8px' }}>
          <h2>Step 1: Seed Demo Data</h2>
          <button onClick={seedDemoData} disabled={loading} style={{
            backgroundColor: '#28a745',
            color: 'white',
            border: 'none',
            padding: '0.5rem 1rem',
            borderRadius: '4px',
            cursor: 'pointer'
          }}>
            {loading ? 'Loading...' : 'Seed Demo Data'}
          </button>
        </div>

        {/* Step 2: Send Magic Link */}
        <div style={{ marginBottom: '2rem', padding: '1rem', border: '1px solid #ddd', borderRadius: '8px' }}>
          <h2>Step 2: Send Magic Link</h2>
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="Enter email address"
            style={{ padding: '0.5rem', marginRight: '1rem', width: '300px' }}
          />
          <button onClick={sendMagicLink} disabled={loading} style={{
            backgroundColor: '#007bff',
            color: 'white',
            border: 'none',
            padding: '0.5rem 1rem',
            borderRadius: '4px',
            cursor: 'pointer'
          }}>
            {loading ? 'Sending...' : 'Send Magic Link'}
          </button>
        </div>

        {/* Step 3: Verify Token */}
        <div style={{ marginBottom: '2rem', padding: '1rem', border: '1px solid #ddd', borderRadius: '8px' }}>
          <h2>Step 3: Test Token (from success page)</h2>
          <input
            type="text"
            value={token}
            onChange={(e) => setToken(e.target.value)}
            placeholder="Paste access token here"
            style={{ padding: '0.5rem', marginRight: '1rem', width: '400px' }}
          />
          <button onClick={verifyToken} disabled={loading || !token} style={{
            backgroundColor: '#ffc107',
            color: 'black',
            border: 'none',
            padding: '0.5rem 1rem',
            borderRadius: '4px',
            cursor: 'pointer'
          }}>
            {loading ? 'Verifying...' : 'Verify Token'}
          </button>
        </div>

        {/* Step 4: Test API Endpoints */}
        <div style={{ marginBottom: '2rem', padding: '1rem', border: '1px solid #ddd', borderRadius: '8px' }}>
          <h2>Step 4: Test API Endpoints</h2>
          <button onClick={getProfile} disabled={loading || !token} style={{
            backgroundColor: '#17a2b8',
            color: 'white',
            border: 'none',
            padding: '0.5rem 1rem',
            borderRadius: '4px',
            cursor: 'pointer',
            marginRight: '1rem'
          }}>
            {loading ? 'Loading...' : 'Get Profile'}
          </button>
          <button onClick={testPendingTasks} disabled={loading || !token} style={{
            backgroundColor: '#6f42c1',
            color: 'white',
            border: 'none',
            padding: '0.5rem 1rem',
            borderRadius: '4px',
            cursor: 'pointer'
          }}>
            {loading ? 'Loading...' : 'Test Pending Tasks'}
          </button>
        </div>

        {/* Messages */}
        {message && (
          <div style={{ 
            padding: '1rem', 
            backgroundColor: message.startsWith('✅') ? '#d4edda' : '#f8d7da',
            border: message.startsWith('✅') ? '1px solid #c3e6cb' : '1px solid #f5c6cb',
            borderRadius: '4px',
            marginBottom: '1rem'
          }}>
            {message}
          </div>
        )}

        {/* Profile Data */}
        {profileData && (
          <div style={{ 
            padding: '1rem', 
            backgroundColor: '#f8f9fa',
            border: '1px solid #dee2e6',
            borderRadius: '4px'
          }}>
            <h3>Profile Data:</h3>
            <pre style={{ fontSize: '0.9rem' }}>{JSON.stringify(profileData, null, 2)}</pre>
          </div>
        )}
      </main>
    </>
  )
}