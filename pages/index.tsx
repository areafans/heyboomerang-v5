import Head from 'next/head'

export default function Home() {
  return (
    <>
      <Head>
        <title>Boomerang API</title>
        <meta name="description" content="Boomerang voice-first task management API" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </Head>
      <main style={{ padding: '2rem', fontFamily: 'system-ui, sans-serif' }}>
        <h1>🎯 Boomerang API</h1>
        <p>Voice-first task management backend is running.</p>
        <div style={{ marginTop: '2rem' }}>
          <h2>API Status</h2>
          <ul>
            <li>✅ Next.js Server</li>
            <li>⏳ Supabase Database (pending)</li>
            <li>⏳ OpenAI Integration (pending)</li>
            <li>⏳ Twilio SMS (pending)</li>
            <li>⏳ SendGrid Email (pending)</li>
          </ul>
        </div>
        <div style={{ marginTop: '2rem' }}>
          <h2>Available Endpoints</h2>
          <ul>
            <li><code>GET /api/health</code> - Health check</li>
            <li><code>POST /api/capture</code> - Process voice transcriptions</li>
            <li><code>GET /api/tasks/pending</code> - Get pending tasks</li>
          </ul>
        </div>
      </main>
    </>
  )
}