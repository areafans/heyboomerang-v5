import Head from 'next/head'
import { useRouter } from 'next/router'
import { useEffect, useState } from 'react'

export default function AuthSuccess() {
  const router = useRouter()
  const [token, setToken] = useState<string>('')
  const [userId, setUserId] = useState<string>('')

  useEffect(() => {
    if (router.query.token && router.query.user_id) {
      setToken(router.query.token as string)
      setUserId(router.query.user_id as string)
    }
  }, [router.query])

  const copyToClipboard = async (text: string) => {
    try {
      await navigator.clipboard.writeText(text)
      alert('Copied to clipboard!')
    } catch (err) {
      console.error('Failed to copy:', err)
    }
  }

  return (
    <>
      <Head>
        <title>Authentication Success - Boomerang</title>
      </Head>
      <main style={{ padding: '2rem', fontFamily: 'system-ui, sans-serif', maxWidth: '800px', margin: '0 auto' }}>
        <div style={{ textAlign: 'center', marginBottom: '2rem' }}>
          <h1 style={{ color: '#22c55e' }}>✅ Authentication Successful!</h1>
          <p>You have been successfully authenticated with Boomerang.</p>
        </div>

        <div style={{ backgroundColor: '#f8f9fa', padding: '1.5rem', borderRadius: '8px', marginBottom: '2rem' }}>
          <h2>Authentication Details</h2>
          
          <div style={{ marginBottom: '1rem' }}>
            <strong>User ID:</strong>
            <div style={{ 
              fontFamily: 'monospace', 
              fontSize: '0.9rem', 
              backgroundColor: '#e9ecef', 
              padding: '0.5rem', 
              borderRadius: '4px', 
              marginTop: '0.5rem',
              wordBreak: 'break-all',
              cursor: 'pointer'
            }} onClick={() => copyToClipboard(userId)}>
              {userId || 'Loading...'}
            </div>
          </div>

          <div style={{ marginBottom: '1rem' }}>
            <strong>Access Token:</strong>
            <div style={{ 
              fontFamily: 'monospace', 
              fontSize: '0.8rem', 
              backgroundColor: '#e9ecef', 
              padding: '0.5rem', 
              borderRadius: '4px', 
              marginTop: '0.5rem',
              wordBreak: 'break-all',
              maxHeight: '100px',
              overflow: 'auto',
              cursor: 'pointer'
            }} onClick={() => copyToClipboard(token)}>
              {token || 'Loading...'}
            </div>
            <small style={{ color: '#666' }}>Click to copy to clipboard</small>
          </div>
        </div>

        <div style={{ backgroundColor: '#e1f5fe', padding: '1.5rem', borderRadius: '8px' }}>
          <h3>For iOS Development:</h3>
          <ol>
            <li>Copy the access token above</li>
            <li>Use it in your iOS app for API authentication</li>
            <li>Add it to the Authorization header: <code>Bearer {'{token}'}</code></li>
            <li>Test with endpoints like <code>/api/user/profile</code></li>
          </ol>
        </div>

        <div style={{ textAlign: 'center', marginTop: '2rem' }}>
          <button 
            onClick={() => window.close()}
            style={{
              backgroundColor: '#007bff',
              color: 'white',
              border: 'none',
              padding: '0.75rem 1.5rem',
              borderRadius: '4px',
              cursor: 'pointer',
              fontSize: '1rem'
            }}
          >
            Close Window
          </button>
        </div>
      </main>
    </>
  )
}