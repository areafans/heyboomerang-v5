# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Boomerang is a voice-first iOS app for small service businesses. Users capture voice notes throughout their workday, which are automatically processed into actionable tasks. The app handles automated follow-ups, reminders, and campaigns after user verification.

**Key Components:**
- Native iOS app (Swift/SwiftUI) for voice capture and task review
- Next.js backend API on Vercel for task processing
- Supabase (PostgreSQL) for data storage and authentication
- OpenAI integration for AI task generation with user context
- Twilio (SMS) and SendGrid (email) for message delivery

## Technical Architecture

### Stack
- **iOS App**: Native Swift/SwiftUI
- **Backend**: Next.js on Vercel  
- **Database**: Supabase (PostgreSQL + Auth)
- **APIs**: OpenAI, Twilio, SendGrid
- **Voice**: iOS native speech recognition

### Core Data Flow
```
Voice Capture → Speech Recognition → AI Processing → Task Generation → User Review → Automated Execution
```

### Database Structure
Key tables: `users`, `contacts`, `captures`, `tasks`, `messages`, `user_context`, `contact_insights`

## Development Commands

Since this is a planning-stage project with only a PRD document, no build/test/lint commands are available yet. The codebase will likely include:

**When implemented:**
- iOS project: Standard Xcode build commands
- Backend: `npm run dev`, `npm run build`, `npm test`, `npm run lint`
- Database: Supabase CLI commands for migrations

## Key API Endpoints (Planned)

### Core Endpoints
- `POST /api/capture` - Process voice transcriptions into tasks
- `GET /api/tasks/pending` - Retrieve pending tasks for review
- `PUT /api/tasks/:id` - Update task status (approve/skip)
- `POST /api/tasks/bulk-approve` - Batch approve multiple tasks

### Context System
- `GET /api/context/user/:userId` - Get user business context
- `POST /api/context/learn` - Update learning from user actions

## Context & Learning System

The app maintains intelligent context for each user:
- **Business Context**: Name, type, location, messaging style
- **Message Examples**: Last 20 approved messages for style learning
- **Contact Patterns**: Interaction history and preferences
- **Timing Preferences**: When to send different types of messages

## Core User Flow

1. **Capture**: Hold button → speak → release (10 second max, 32/day limit)
2. **Process**: AI generates tasks from transcription using user context
3. **Review**: Evening verification of contact details and message content
4. **Execute**: Automated sending via SMS/email with delivery tracking

## iOS App Key Screens

1. **Main Screen**: Large microphone button, capture counter, daily summary
2. **Task Review**: Group summary → individual task verification → contact details → timing selection
3. **Dashboard**: Weekly metrics, top contacts, completion rates
4. **Settings**: Business info, notifications, subscription

## Development Phases

- **Phase 1**: Foundation (Vercel + Supabase setup, auth, basic API)
- **Phase 2**: iOS core (Voice capture, task review, contact management)
- **Phase 3**: AI processing (Task generation with context, message creation)
- **Phase 4**: Execution (SMS/email integration, delivery tracking)
- **Phase 5**: Polish (Dashboard, analytics, optimization)
- **Phase 6**: Intelligence (Advanced learning, pattern recognition)

## Key Product Constraints

- Single iOS app (no web dashboard in v1)
- Voice-first interaction model
- 32 captures per day limit
- Tasks auto-archive after 7 days, dismiss after 30 days
- $49/month subscription with 7-day free trial
- Focus on simplicity - "can my mom use this?" test

## Privacy & Data

- User-scoped context (no sharing between accounts)
- Minimal data collection
- Easy export/deletion capabilities
- All voice processing uses iOS native speech recognition (stays on device)

## Development Methodology

**Current Phase: Polished Clickable Prototype**
- Complete navigation structure with 5-tab design
- All screens functional with realistic mock data
- Enhanced UI polish with SwiftUI animations and SF Symbols
- Ready for user testing and validation

**Systematic Approach:**
1. ✅ **Foundation**: App builds and runs reliably
2. ✅ **Onboarding**: Complete 4-screen user setup flow
3. ✅ **Navigation**: 5-tab structure matching user workflow
4. ✅ **Polish**: SwiftUI enhancements, animations, consistent design
5. 🎯 **Next**: Task review flow completion or backend integration

**Key Principles:**
- Never jump ahead to complex features before foundation is solid
- Build UI first, add functionality second
- Test each phase thoroughly before moving forward
- "Can my mom use this?" simplicity test throughout
- Commit working states frequently

**Mock Data Strategy:**
- Mock business: "Mike's Construction" - general contracting company
- Mock user: "Mike Thompson" with realistic business info
- Mock voice transcriptions: contractor-focused (kitchen demos, drywall orders, deck projects)
- Mock tasks: various states with realistic messages
- Mock delivery results: status tracking for completed messages

**Navigation Structure:**
- **Onboarding**: Welcome → Business Setup (name/business/description) → Permissions → Tutorial
- **Main App Tabs**: Summary (morning results) | Tasks (evening review) | Capture (center) | Dashboard (metrics) | Profile (settings)
- **Key UX**: Morning check summary → All day capture → Evening review tasks

**UI Polish Applied:**
- Hierarchical SF Symbols throughout
- Consistent tab icon design (no background circles)
- Pull-to-refresh on Summary and Tasks tabs
- Haptic feedback on interactions
- Spring animations for smooth transitions
- Press-and-hold voice capture with visual feedback