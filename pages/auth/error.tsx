import Head from 'next/head'
import { useRouter } from 'next/router'
import { useEffect, useState } from 'react'

export default function AuthError() {
  const router = useRouter()
  const [errorMessage, setErrorMessage] = useState<string>('')

  useEffect(() => {
    if (router.query.message) {
      setErrorMessage(decodeURIComponent(router.query.message as string))
    }
  }, [router.query])

  return (
    <>
      <Head>
        <title>Authentication Error - Boomerang</title>
      </Head>
      <main style={{ padding: '2rem', fontFamily: 'system-ui, sans-serif', maxWidth: '600px', margin: '0 auto' }}>
        <div style={{ textAlign: 'center', marginBottom: '2rem' }}>
          <h1 style={{ color: '#dc3545' }}>❌ Authentication Failed</h1>
          <p>There was an error during the authentication process.</p>
        </div>

        <div style={{ backgroundColor: '#f8d7da', padding: '1.5rem', borderRadius: '8px', marginBottom: '2rem', border: '1px solid #f5c6cb' }}>
          <h3 style={{ color: '#721c24', marginTop: 0 }}>Error Details:</h3>
          <p style={{ color: '#721c24', fontFamily: 'monospace', fontSize: '0.9rem' }}>
            {errorMessage || 'Unknown error occurred'}
          </p>
        </div>

        <div style={{ backgroundColor: '#fff3cd', padding: '1.5rem', borderRadius: '8px', border: '1px solid #ffeaa7' }}>
          <h3 style={{ color: '#856404', marginTop: 0 }}>What to try:</h3>
          <ul style={{ color: '#856404' }}>
            <li>Check that the magic link hasn't expired (links expire after 24 hours)</li>
            <li>Make sure you're clicking the link from the same device/browser</li>
            <li>Try requesting a new magic link</li>
            <li>Contact support if the problem persists</li>
          </ul>
        </div>

        <div style={{ textAlign: 'center', marginTop: '2rem' }}>
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
      </main>
    </>
  )
}