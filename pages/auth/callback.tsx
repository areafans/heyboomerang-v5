import Head from 'next/head'
import { useRouter } from 'next/router'
import { useEffect, useState } from 'react'

export default function AuthCallback() {
  const router = useRouter()
  const [status, setStatus] = useState<'loading' | 'success' | 'error'>('loading')
  const [message, setMessage] = useState('')
  const [tokenData, setTokenData] = useState<{
    accessToken: string
    refreshToken: string
    userId: string
  } | null>(null)

  useEffect(() => {
    const handleCallback = async () => {
      try {
        // Extract tokens from URL fragment (client-side only)
        const fragment = window.location.hash.substring(1)
        const params = new URLSearchParams(fragment)
        
        const accessToken = params.get('access_token')
        const refreshToken = params.get('refresh_token')
        const error = params.get('error')
        const errorDescription = params.get('error_description')

        if (error) {
          setStatus('error')
          setMessage(errorDescription || error)
          return
        }

        if (!accessToken) {
          setStatus('error')
          setMessage('No access token found in callback')
          return
        }

        // Verify the token with our API and create user profile
        const response = await fetch('/api/auth/verify-token', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ token: accessToken }),
        })

        const data = await response.json()

        if (response.ok) {
          setStatus('success')
          setMessage('Authentication successful!')
          setTokenData({
            accessToken,
            refreshToken: refreshToken || '',
            userId: data.user?.id || ''
          })

          // Create user profile in our database if needed
          await createUserProfile(accessToken, data.user)

        } else {
          setStatus('error')
          setMessage(data.error || 'Token verification failed')
        }

      } catch (error) {
        console.error('Callback error:', error)
        setStatus('error')
        setMessage('Authentication failed')
      }
    }

    // Only run on client side
    if (typeof window !== 'undefined') {
      handleCallback()
    }
  }, [])

  const createUserProfile = async (token: string, user: any) => {
    try {
      // Check if user exists in our database, create if not
      const response = await fetch('/api/user/profile', {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
        },
      })

      if (response.status === 401 || response.status === 404) {
        // User doesn't exist, create them
        const createResponse = await fetch('/api/user/profile', {
          method: 'PUT',
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            businessName: null,
            businessType: null,
            businessDescription: null,
          }),
        })

        if (!createResponse.ok) {
          console.error('Failed to create user profile')
        }
      }
    } catch (error) {
      console.error('Profile creation error:', error)
    }
  }

  const copyToClipboard = async (text: string) => {
    try {
      await navigator.clipboard.writeText(text)
      alert('Copied to clipboard!')
    } catch (err) {
      console.error('Failed to copy:', err)
    }
  }

  const continueToApp = () => {
    // For now, redirect to test page with token
    // In production, this would be handled by iOS app URL scheme
    router.push(`/test-auth?token=${tokenData?.accessToken}`)
  }

  return (
    <>
      <Head>
        <title>Authentication Callback - Boomerang</title>
      </Head>
      <main style={{ padding: '2rem', fontFamily: 'system-ui, sans-serif', maxWidth: '600px', margin: '0 auto' }}>
        <div style={{ textAlign: 'center', marginBottom: '2rem' }}>
          <h1>🔄 Processing Authentication...</h1>
        </div>

        {status === 'loading' && (
          <div style={{ textAlign: 'center' }}>
            <div style={{ fontSize: '2rem', marginBottom: '1rem' }}>⏳</div>
            <p>Verifying your authentication...</p>
          </div>
        )}

        {status === 'success' && tokenData && (
          <div>
            <div style={{ textAlign: 'center', marginBottom: '2rem' }}>
              <div style={{ fontSize: '2rem', marginBottom: '1rem', color: '#22c55e' }}>✅</div>
              <h2 style={{ color: '#22c55e' }}>Authentication Successful!</h2>
              <p>{message}</p>
            </div>

            <div style={{ backgroundColor: '#f8f9fa', padding: '1.5rem', borderRadius: '8px', marginBottom: '2rem' }}>
              <h3>Authentication Details</h3>
              
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
                }} onClick={() => copyToClipboard(tokenData.userId)}>
                  {tokenData.userId}
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
                }} onClick={() => copyToClipboard(tokenData.accessToken)}>
                  {tokenData.accessToken}
                </div>
                <small style={{ color: '#666' }}>Click to copy to clipboard</small>
              </div>
            </div>

            <div style={{ textAlign: 'center' }}>
              <button 
                onClick={continueToApp}
                style={{
                  backgroundColor: '#007bff',
                  color: 'white',
                  border: 'none',
                  padding: '0.75rem 1.5rem',
                  borderRadius: '4px',
                  cursor: 'pointer',
                  fontSize: '1rem',
                  marginRight: '1rem'
                }}
              >
                Continue to Test Page
              </button>
              <button 
                onClick={() => window.close()}
                style={{
                  backgroundColor: '#6c757d',
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
          </div>
        )}

        {status === 'error' && (
          <div>
            <div style={{ textAlign: 'center', marginBottom: '2rem' }}>
              <div style={{ fontSize: '2rem', marginBottom: '1rem', color: '#dc3545' }}>❌</div>
              <h2 style={{ color: '#dc3545' }}>Authentication Failed</h2>
            </div>

            <div style={{ backgroundColor: '#f8d7da', padding: '1.5rem', borderRadius: '8px', marginBottom: '2rem', border: '1px solid #f5c6cb' }}>
              <h3 style={{ color: '#721c24', marginTop: 0 }}>Error Details:</h3>
              <p style={{ color: '#721c24' }}>{message}</p>
            </div>

            <div style={{ textAlign: 'center' }}>
              <button 
                onClick={() => router.push('/test-auth')}
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
                Try Again
              </button>
            </div>
          </div>
        )}
      </main>
    </>
  )
}