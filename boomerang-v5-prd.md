# Boomerang - Product Requirements Document

## Executive Summary

Boomerang is a voice-first iOS app designed for small service businesses. Users capture voice notes throughout their workday, which are automatically processed into actionable tasks. During evening review, users verify contact details and approve tasks with simple taps. The app then executes automated follow-ups, reminders, and campaigns.

**Key Value**: Transform stream-of-consciousness voice notes into automated business growth - all from your iPhone.

## Product Principles

1. **Simplicity First** - Every feature must pass the "can my mom use this?" test
2. **Voice-Native** - Designed for hands-free, in-the-moment capture
3. **Trust Through Transparency** - Users verify facts, AI handles the rest
4. **Incremental Value** - Useful from day one, more valuable over time
5. **iOS-First** - Fully native experience, no web required

## User Personas

### Primary: Solo Service Provider
- **Who**: Hair stylist, contractor, personal trainer
- **Pain**: Too busy serving clients to handle follow-ups
- **Need**: Simple way to capture tasks without stopping work
- **Success**: Sends 10+ follow-ups they wouldn't have otherwise

### Secondary: Small Team Owner
- **Who**: Restaurant owner, dental practice, auto shop
- **Pain**: Inconsistent customer communication across team
- **Need**: Standardize follow-ups without complexity
- **Success**: Improved review ratings and repeat business

## Core User Flow

```
Morning → Open app → See daily summary → Start work
↓
During day → Think of task → Hold button → Speak → Release → Continue work
↓
Evening → Open app → Review tasks → Verify details → Approve → Send
↓
Next morning → See results → Repeat
```

## Technical Architecture

### Stack
- **iOS App**: Native Swift/SwiftUI
- **Backend**: Next.js on Vercel
- **Database**: Supabase (PostgreSQL + Auth)
- **APIs**: OpenAI, Twilio, SendGrid
- **Voice**: iOS native speech recognition

### Infrastructure
```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   iOS App   │────▶│  Vercel API │────▶│   External  │
│   (Swift)   │     │   (Next.js) │     │    APIs     │
└─────────────┘     └──────┬──────┘     └─────────────┘
                           │
                    ┌──────▼──────┐
                    │  Supabase   │
                    │  Database   │
                    └─────────────┘
```

## Database Schema

```sql
-- Core tables for MVP
users (
  id uuid PRIMARY KEY,
  email text UNIQUE,
  business_name text,
  business_type text,
  city text,
  state text,
  timezone text, -- auto-detected from city/state
  subscription_status text DEFAULT 'trial',
  trial_ends_at timestamp,
  daily_capture_count integer DEFAULT 0,
  daily_capture_reset timestamp
)

contacts (
  id uuid PRIMARY KEY,
  user_id uuid REFERENCES users(id),
  name text NOT NULL,
  email text,
  phone text,
  type text DEFAULT 'client', -- client/vendor/employee
  notes jsonb,
  last_contact timestamp,
  created_at timestamp DEFAULT now()
)

captures (
  id uuid PRIMARY KEY,
  user_id uuid REFERENCES users(id),
  transcription text,
  created_at timestamp DEFAULT now()
)

tasks (
  id uuid PRIMARY KEY,
  user_id uuid REFERENCES users(id),
  capture_id uuid REFERENCES captures(id),
  type text, -- follow_up/reminder/campaign/note
  status text DEFAULT 'pending', -- pending/approved/sent/skipped/archived/dismissed
  contact_id uuid REFERENCES contacts(id),
  contact_name text, -- for ambiguous contacts
  message text,
  scheduled_for timestamp,
  created_at timestamp DEFAULT now(),
  archived_at timestamp, -- set after 7 days
  dismissed_at timestamp -- set after 30 days
)

messages (
  id uuid PRIMARY KEY,
  task_id uuid REFERENCES tasks(id),
  contact_id uuid REFERENCES contacts(id),
  type text, -- sms/email
  content text,
  status text, -- sent/delivered/failed
  sent_at timestamp DEFAULT now()
)

-- Learning and context tables
user_context (
  user_id uuid PRIMARY KEY REFERENCES users(id),
  message_style_examples text[], -- Last 20 approved messages
  preferred_timing jsonb, -- {"follow_up": "2_days", "reminder": "1_day"}
  common_phrases text[], -- Frequently used words/phrases
  business_patterns jsonb, -- {"slow_days": ["Wednesday"], "busy_times": ["Saturday AM"]}
  updated_at timestamp DEFAULT now()
)

contact_insights (
  contact_id uuid PRIMARY KEY REFERENCES contacts(id),
  visit_frequency integer, -- average days between visits
  preferred_services text[],
  last_topics text[], -- recent discussion topics
  engagement_score float, -- response rate to messages
  updated_at timestamp DEFAULT now()
)
```

## API Specification

### Capture Endpoint
```
POST /api/capture
Body: { 
  transcription: string,
  duration: number 
}
Response: { 
  captureId: string,
  suggestedTasks: Task[] | null
}

Daily limit: 32 captures
Processing: <2 seconds
```

### API Endpoints with Context

#### Capture Endpoint (Enhanced)
```
POST /api/capture
Body: { 
  transcription: string,
  duration: number 
}

Processing:
1. Build user context
2. Call OpenAI with context
3. Parse response into tasks
4. Return suggested tasks

Response: { 
  captureId: string,
  suggestedTasks: Task[] | null
}
```

#### Context Endpoints
```
GET /api/context/user/:userId
Response: {
  businessContext: object,
  messageExamples: string[],
  timingPreferences: object
}

POST /api/context/learn
Body: {
  taskId: string,
  action: 'approved' | 'edited' | 'skipped'
}
```

### Review Endpoints
```
GET /api/tasks/pending
Query: { includeArchived?: boolean }
Response: { 
  active: Task[],
  archived: Task[],
  stats: { total: number, needsInfo: number }
}

PUT /api/tasks/:id
Body: { 
  status: 'approved' | 'skipped',
  contactId?: string,
  scheduledFor?: string,
  contactUpdates?: {
    phone?: string,
    email?: string
  }
}

POST /api/tasks/bulk-approve
Body: { 
  taskIds: string[],
  scheduledFor: string
}
```

### Analytics Endpoints
```
GET /api/analytics/dashboard
Response: {
  messagesThisWeek: number,
  messagesThisMonth: number,
  topContacts: Contact[],
  completionRate: number
}
```

## iOS App Specifications

### Core Screens

**1. Main Screen (Voice Capture)**
- Large microphone button (center)
- Subtle capture counter (e.g., "7/32")
- Today's summary card (top)
- Quick access to review (if pending tasks)

**2. Task Review Flow**
```
// Group Summary
┌──────────────────┐
│ 12 tasks ready   │
│                  │
│ Follow-ups (5) → │
│ Reminders (3) →  │
│ Notes (4) →      │
└──────────────────┘

// Individual Task
┌──────────────────┐
│ Follow-up 1 of 5 │
│                  │
│ "Mary Johns"     │
│ Did you mean?    │
│ ◉ Mary Johnson   │
│ ○ New: Mary Johns│
│                  │
│ [Continue]       │
└──────────────────┘

// Contact Details
┌──────────────────┐
│ Mary Johnson     │
│                  │
│ 📱 Add phone     │
│ ✉️ Add email     │
│                  │
│ [Continue]       │
└──────────────────┘

// Timing Selection
┌──────────────────┐
│ When to send?    │
│                  │
│ [Tomorrow AM]    │
│ [Tomorrow PM]    │
│ [In 2 days]      │
│                  │
│ Message preview: │
│ "Thanks for..."  │
│                  │
│ [Approve ✓]      │
└──────────────────┘
```

**3. Dashboard**
- Weekly message count (graph)
- Top contacts engaged
- Task completion rate
- Simple, glanceable metrics

**4. Settings**
- Business info
- Notification preferences
- Export data
- Subscription status

### Key Interactions

**Voice Capture**
- Press and hold to record
- Release to stop (10 second max)
- See transcription briefly
- Haptic feedback on success

**Contact Entry**
- Phone: Native number pad with formatting
- Email: Simple text field (no predictions)
- Name corrections: Suggest common spellings

**Task Review**
- Tap-based (no swipes)
- 2-3 taps per task average
- Bulk approve for similar tasks
- Exit and resume anytime

### Visual Design
- Clean, minimal interface
- Large tap targets (44pt minimum)
- High contrast for outdoor use
- Subtle animations for feedback
- Native iOS components where possible

## Features by Phase

### Phase 0: Interactive Mockup ✓
- Clickable prototype
- Mock data flow
- Validate UX assumptions

### Phase 1: Foundation (Weeks 1-2)
- Vercel + Supabase setup
- Authentication (magic link)
- Basic data models
- API structure
- Base context system setup

### Phase 2: iOS App Core (Weeks 3-4)
- Voice capture UI
- Native speech recognition
- Task review flow
- Contact management
- Basic context building for API calls

### Phase 3: Task Processing (Weeks 5-6)
- AI task generation with context
- Message creation (general professional tone)
- Contact matching logic
- Task lifecycle (pending → archived → dismissed)
- Initial learning capture (store approved messages)

### Phase 4: Execution (Weeks 7-8)
- Twilio SMS integration
- SendGrid email integration
- Delivery tracking
- Push notifications
- Context updates from approvals

### Phase 5: Polish & Analytics (Weeks 9-10)
- Dashboard screen
- Performance optimization
- Error handling
- App Store preparation

### Phase 6: Learning & Intelligence (Weeks 11-12)
- Pattern recognition implementation
- Adaptive message generation
- Contact insights tracking
- Context optimization for token efficiency

## Key Product Decisions

### What We're Building
- Single iOS app (no web required)
- Voice → Task automation
- Simple contact verification
- Auto-generated messages
- Basic analytics dashboard

### What We're NOT Building (v1)
- Android app
- Web dashboard
- Message editing
- Complex scheduling
- Team features
- Appointment booking
- Payment processing

### Task Lifecycle
- **Active**: 0-7 days (shown in review)
- **Archived**: 7-30 days (accessible but tucked away)
- **Dismissed**: 30+ days (auto-removed)

### Message Generation
- General professional tone
- Appropriate for any business type
- No user editing required
- AI handles context appropriately

## Pricing Model
- Single tier: $49/month
- 7-day free trial
- Includes:
  - 32 voice captures/day
  - 2,000 messages/month
  - All features
  - Data export

## Success Metrics

### Usage Metrics
- Daily active users
- Captures per user per day
- Task approval rate (target: >80%)
- Time to review completion

### Business Metrics
- Trial → Paid conversion (target: >20%)
- Monthly churn rate (target: <5%)
- 30-day retention (target: >70%)
- NPS score (target: >50)

### Feature Success
- Capture → Task accuracy
- Contact match success rate
- Message delivery rate
- User-reported time saved

## Risk Mitigation

### Technical Risks
- **API Costs**: Cache AI responses, batch process
- **Speech Recognition**: Use iOS native (free, reliable)
- **Delivery Rates**: Premium Twilio/SendGrid accounts

### Product Risks
- **Low Adoption**: Focus on single vertical first
- **Review Fatigue**: Auto-archive old tasks
- **Contact Confusion**: Clear disambiguation UI

## Context & Learning System

### Context Management
The app maintains user-specific context for intelligent task generation:

**1. Base Context (Per User)**
- Business name, type, location
- Message style examples (last 20 approved)
- Preferred timing patterns
- Common phrases and terminology

**2. Dynamic Context (Per Request)**
- Relevant contacts mentioned
- Recent interactions with those contacts
- Current day/time considerations
- Recent similar tasks

**3. Learning Pipeline**
```
User approves task → Update message examples
                  → Update timing preferences
                  → Update contact insights
                  → Refresh context cache
```

### Context Building for API Calls
```javascript
// Each API call includes relevant context
const context = {
  business: await getUserBusinessContext(userId),
  style: await getMessageStyleExamples(userId, 5),
  contacts: await getRelevantContacts(userId, transcription),
  patterns: await getUserPatterns(userId)
};

// OpenAI call with context
const systemPrompt = buildSystemPrompt(context);
const userPrompt = transcription;
```

### Privacy & Multi-Tenancy
- All context is user-scoped in database
- No sharing between accounts
- Context deleted on account deletion
- Exportable as part of user data

## Development Guidelines

### Code Principles
- Fail gracefully (never lose a capture)
- Offline-first (queue when no connection)
- Instant feedback (optimistic UI)
- Accessibility from day one

### Data Privacy
- Minimal data collection
- Easy export/deletion
- No contact sharing between accounts
- Clear privacy policy

### Testing Strategy
- TestFlight beta (50 users)
- Focus on service businesses
- Daily usage tracking
- Weekly feedback calls

## Future Vision (Post-MVP)

### Version 2.0
- Android app
- Web dashboard (power users)
- Team accounts
- Calendar integration
- Advanced message customization

### Version 3.0
- AI insights ("Wednesdays are slow")
- Automated campaigns
- Industry templates
- White-label option

## Appendix: Voice → Task Examples

```
"Just finished with Mary Johnson"
→ Follow-up to Mary Johnson in 2 days

"Need to order shampoo"
→ Reminder: Order shampoo (tomorrow)

"Add new client John Smith 555-1234"
→ New contact + prompt for email

"Running a special next week"
→ Campaign: Send to all clients

"Having a great day"
→ No task generated

"Mike and his wife Sarah came in"
→ Follow-up to Mike (AI determines single task)
```