# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🚨 CRITICAL: Always Use the Project Todo List

**BEFORE starting any work:**
1. **Read the current Project Todo List below** to understand exactly where we are
2. **Update todo status** as you complete tasks (✅ = done, 🎯 = in progress, ❌ = not started)
3. **Add new todos** when you discover additional work needed
4. **Commit todo updates** to preserve progress across context resets

**This todo list is our persistent memory system - treat it as the single source of truth for project status.**

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

**iOS Project (Current):**
- Build and run: Open `HeyBoomerangIOS.xcodeproj` in Xcode and use Cmd+R
- iOS Simulator testing available for all UI functionality
- No specific lint/test commands configured yet - standard Xcode build process

**Backend (Planned):**
- `npm run dev`, `npm run build`, `npm test`, `npm run lint`
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

1. **Voice Capture**: Large microphone button with press-and-hold, capture counter, transcription preview
2. **Summary**: Morning results with impact cards, hot leads, and message delivery status
3. **Tasks**: Evening review of pending tasks with tap-to-review interface
4. **Dashboard**: AI-powered business growth story with performance metrics and smart insights
5. **Profile**: User settings, business info, subscription status, and app preferences

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

## 📋 PROJECT TODO LIST

### **PHASE 0: FOUNDATION & PROTOTYPE** 
✅ Set up Xcode project with proper structure  
✅ Create core data models (User, Contact, Capture, Task)  
✅ Build basic UI structure with SwiftUI  
✅ Implement mock VoiceCaptureService for testing  
✅ Create complete 4-screen onboarding flow  
✅ Design 5-tab navigation structure (Summary|Tasks|Capture|Dashboard|Profile)  
✅ Polish UI with SF Symbols, animations, and consistent design  
✅ Add pull-to-refresh and haptic feedback  
✅ Fix all compilation errors and warnings  
✅ Create comprehensive CLAUDE.md documentation  

### **PHASE 1: COMPLETE TASK REVIEW FLOW (CURRENT PRIORITY)**
❌ **1.1** Implement PRD-specified 5-step task review flow:
   - ❌ Group Summary screen (Follow-ups (5) → Reminders (3) → Notes (4))
   - ❌ Contact Disambiguation ("Mary Johns" vs "Mary Johnson" selection)
   - ❌ Contact Details Entry (add phone/email forms)
   - ❌ Timing Selection (Tomorrow AM, Tomorrow PM, In 2 days)
   - ❌ Message Preview & Final Approval
❌ **1.2** Add swipe actions on task cards (approve/skip)  
❌ **1.3** Implement bulk approval functionality  
❌ **1.4** Add proper navigation between review steps  
❌ **1.5** Handle edge cases (no tasks, network errors)  

### **PHASE 2: REAL VOICE CAPTURE**
❌ **2.1** Replace mock VoiceCaptureService with real iOS Speech framework  
❌ **2.2** Add proper microphone and speech recognition permissions  
❌ **2.3** Implement actual speech-to-text with error handling  
❌ **2.4** Add audio level visualization during recording  
❌ **2.5** Handle speech recognition confidence and errors  
❌ **2.6** Test voice capture accuracy with real audio  

### **PHASE 3: ENHANCED UX POLISH**
❌ **3.1** Improve empty states across all screens  
❌ **3.2** Add loading states for future API integration  
❌ **3.3** Implement better contact management UI  
❌ **3.4** Add user settings and preferences  
❌ **3.5** Optimize performance and memory usage  
❌ **3.6** Add accessibility support (VoiceOver, Dynamic Type)  

### **PHASE 4: BACKEND FOUNDATION** 
❌ **4.1** Set up Vercel + Next.js API structure  
❌ **4.2** Configure Supabase database with PRD schema  
❌ **4.3** Implement authentication (magic link)  
❌ **4.4** Create API endpoints matching current mock data  
❌ **4.5** Add user context and learning system foundation  

### **PHASE 5: API INTEGRATION**
❌ **5.1** Connect iOS app to real backend APIs  
❌ **5.2** Replace all mock data with database calls  
❌ **5.3** Implement proper error handling and retry logic  
❌ **5.4** Add offline support and data synchronization  
❌ **5.5** Test complete end-to-end flow  

### **PHASE 6: AI & MESSAGE PROCESSING**
❌ **6.1** Integrate OpenAI API for task generation  
❌ **6.2** Implement user context system for personalized messages  
❌ **6.3** Add contact matching and disambiguation logic  
❌ **6.4** Create message generation with business context  
❌ **6.5** Add learning system (store approved messages)  

### **PHASE 7: MESSAGE DELIVERY**
❌ **7.1** Integrate Twilio for SMS delivery  
❌ **7.2** Integrate SendGrid for email delivery  
❌ **7.3** Add delivery tracking and status updates  
❌ **7.4** Implement push notifications for delivery results  
❌ **7.5** Add retry logic for failed deliveries  

### **PHASE 8: PRODUCTION READY**
❌ **8.1** Add comprehensive error logging  
❌ **8.2** Implement analytics and usage tracking  
❌ **8.3** Add subscription and payment integration  
❌ **8.4** Performance optimization and testing  
❌ **8.5** App Store preparation and submission  

### **IMMEDIATE NEXT STEPS** (Priority Order)
1. 🎯 **Start Phase 1.1** - Implement the 5-step task review flow (most critical UX gap)
2. Then **Phase 2.1-2.3** - Add real voice capture (core functionality)
3. Then **Phase 3** polish for user testing readiness

## Recent UI Improvements (Completed)

**Navigation & Branding Consistency:**
- Replaced redundant large navigation titles with unified "Boomerang" branding
- Applied consistent `.navigationBarTitleDisplayMode(.inline)` across all views
- Added translucent material backgrounds (`.regularMaterial`) for professional look
- Standardized VStack spacing to 40pt for page headers (matching Capture page)

**Dashboard Transformation:**
- Complete redesign from basic metrics to AI-focused business growth story
- Added "At a Glance", "Business Impact", "AI Performance", and "AI Insights" sections
- Implemented shared component architecture (ImpactCard, BusinessImpactCard, etc.)
- Fixed section alignment issues by removing internal padding conflicts

**Page Header Consistency:**
- Applied Capture page header style across Summary, Tasks, and Dashboard
- Removed duplicate icons and section headers for cleaner design
- Standardized spacing and typography for consistent user experience

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
- Unified "Boomerang" navigation branding across all views
- Consistent page header spacing (40pt VStack) matching Capture page style
- AI-powered Dashboard with business growth story and automation focus
- Proper section alignment using shared component architecture