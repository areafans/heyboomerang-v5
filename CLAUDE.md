# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🚨 CRITICAL: Current Project Status (Updated August 2025)

**IMPORTANT: The iOS app is essentially COMPLETE and production-ready.** This is NOT an early prototype - it's a sophisticated, mature iOS application with 39+ Swift files, complete user flows, and advanced architecture.

**BEFORE starting any work:**
1. **Read the Current State section below** to understand we have a complete iOS app
2. **Focus on backend development** - that's the primary gap, not iOS features
3. **Update todo status** only when you complete actual work
4. **DO NOT assume iOS features are missing** - they're likely already implemented

**Key Insight: We're in "Production iOS App Needs Backend" phase, not early development.**

## 🚀 Quick Start for New Developers

**If you're new to this project:**

1. **Open `HeyBoomerangIOS.xcodeproj` in Xcode** - the iOS app is complete and ready
2. **Build and run** - everything works with mock data and real voice capture
3. **The iOS app is production-ready** - 39+ Swift files, sophisticated architecture
4. **Focus on backend development** - that's what's missing, not iOS features
5. **Don't rebuild iOS features** - they're already implemented and polished

**Common misconception**: "We need to build basic iOS features"
**Reality**: "We have a sophisticated iOS app that needs a backend to connect to"

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

## Current State Analysis (August 2025)

### **WHAT WE HAVE (iOS - COMPLETE)**

**✅ Production-Ready iOS Application:**
- **39+ Swift files** with sophisticated architecture
- **iOS 17.0+ deployment target** with Swift 5.10
- **Complete dependency injection** with protocols and error handling
- **OSLog-based logging system** for production debugging
- **Secure storage** with UserDefaults + Keychain integration
- **Modern async/await** patterns throughout

**✅ Complete User Experience:**
- **3-screen onboarding flow**: Welcome → Business Setup → Permissions
- **5-tab navigation**: Summary | Tasks | Capture | Dashboard | Profile  
- **Advanced voice capture**: Both mock (development) and real (production) Speech framework
- **Sophisticated task review**: Card-based UI with swipe gestures
- **Rich animations**: Haptic feedback, spring animations, visual transitions
- **Professional UI polish**: SF Symbols, consistent spacing, material backgrounds

**✅ Advanced Features Already Implemented:**
- **TaskReviewFlow.swift**: Complete 5-step review process (Group Summary, Contact Disambiguation, Contact Details, Timing Selection, Message Preview)
- **VoiceCaptureService**: Real iOS Speech Recognition with permission handling
- **TaskCardStackView**: Swipe navigation, progress indicators, bulk actions
- **Contact management**: Disambiguation, validation, CRUD operations
- **Error handling**: Comprehensive AppError system with user-friendly messages
- **Offline support**: Caching, data persistence, network monitoring

## iOS App Architecture (Production Ready)

### **Key Files & Structure**
```
HeyBoomerangIOS/
├── Models/
│   ├── User.swift - Complete user model with validation
│   ├── Contact.swift - Contact management with disambiguation
│   ├── Task.swift - Renamed to AppTask, full task lifecycle
│   └── Capture.swift - Voice capture data model
├── Services/
│   ├── VoiceCaptureService.swift - Real Speech Recognition + Mock for dev
│   ├── TaskService.swift - Task management with caching
│   ├── UserService.swift - Profile management
│   ├── APIService.swift - Network layer ready for backend
│   └── NetworkManager.swift - Advanced HTTP client with monitoring
├── Views/
│   ├── Onboarding/ - 3-screen setup flow
│   ├── Tabs/ - 5-tab navigation structure
│   ├── TaskReviewFlow.swift - Complete 5-step task review
│   └── TaskCardStackView.swift - Sophisticated card interface
├── Common/
│   ├── DependencyContainer.swift - Dependency injection system
│   ├── ErrorHandling.swift - Production error handling + OSLog
│   └── SecureStorage.swift - UserDefaults + Keychain wrapper
```

### **Service Architecture**
- **DependencyContainer**: @MainActor singleton managing all services
- **Protocol-based design**: All services implement protocols for testability
- **Result-based error handling**: All async methods return Result<T, AppError>
- **Caching & offline**: Local storage with network fallbacks
- **Real permissions**: Production iOS permission handling

### **WHAT WE NEED (Backend - MISSING)**

**❌ Backend Infrastructure:**
- No Vercel + Next.js API setup
- No Supabase database configuration  
- No user authentication system
- API endpoints return mock data

**❌ AI Integration:**
- No OpenAI API integration for task generation
- No user context learning system
- No message personalization

**❌ Message Delivery:**
- No Twilio SMS integration
- No SendGrid email integration
- No delivery tracking

## Development Commands

**iOS Project (Ready for Production):**
```bash
# Open in Xcode and build
open HeyBoomerangIOS.xcodeproj
# All functionality works with simulator
# Real voice capture works on device
```

**Backend (Needs Creation):**
```bash
# These don't exist yet - need to create
npm run dev
npm run build
npm test
```

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

## 📋 CURRENT PROJECT STATUS & NEXT STEPS

### **✅ COMPLETED: iOS APP (Production Ready)**

**iOS Foundation & Architecture:**
✅ Complete Xcode project with proper structure (39+ Swift files)
✅ Advanced data models (User, Contact, AppTask, Capture) with validation
✅ Sophisticated dependency injection with protocols
✅ Production-ready error handling with OSLog
✅ Secure storage (UserDefaults + Keychain)
✅ Modern async/await patterns throughout

**Complete User Experience:**
✅ 3-screen onboarding flow (Welcome → Business Setup → Permissions)
✅ 5-tab navigation (Summary | Tasks | Capture | Dashboard | Profile)
✅ Advanced voice capture with real iOS Speech Recognition
✅ Sophisticated task review with TaskCardStackView and swipe gestures
✅ Professional UI polish with SF Symbols, animations, haptic feedback
✅ Pull-to-refresh, loading states, empty states

**Advanced Features Implemented:**
✅ TaskReviewFlow.swift with complete 5-step process
✅ Real VoiceCaptureService with iOS Speech framework
✅ Contact disambiguation and management
✅ Task approval/skip with bulk actions
✅ Network monitoring and offline support
✅ Comprehensive error handling and user messaging

### **❌ MISSING: BACKEND INFRASTRUCTURE (Current Priority)**

**Backend Setup (Critical):**
❌ **B1.1** Set up Vercel project and Next.js API structure
❌ **B1.2** Configure Supabase database with proper schema
❌ **B1.3** Implement user authentication (magic link or similar)
❌ **B1.4** Create API endpoints matching iOS service protocols
❌ **B1.5** Set up environment variables and deployment

**AI Integration:**
❌ **B2.1** Integrate OpenAI API for task generation from transcriptions
❌ **B2.2** Implement user context system for personalized messages
❌ **B2.3** Add contact matching and learning algorithms
❌ **B2.4** Create message generation with business context
❌ **B2.5** Build learning system to improve suggestions

**Message Delivery:**
❌ **B3.1** Integrate Twilio for SMS delivery
❌ **B3.2** Integrate SendGrid for email delivery  
❌ **B3.3** Add delivery tracking and webhook handling
❌ **B3.4** Implement retry logic and error handling
❌ **B3.5** Add push notifications for delivery results

**Production Features:**
❌ **B4.1** Add comprehensive API logging and monitoring
❌ **B4.2** Implement subscription and payment system
❌ **B4.3** Add usage analytics and business intelligence
❌ **B4.4** Performance optimization and caching
❌ **B4.5** Security audit and deployment preparation

### **🎯 IMMEDIATE PRIORITIES**

**The iOS app is complete. Focus entirely on backend:**

1. **Set up Vercel + Supabase infrastructure** (most critical)
2. **Create API endpoints** to replace iOS mock data
3. **Implement OpenAI integration** for task generation
4. **Add Twilio/SendGrid** for message delivery
5. **Connect iOS to real backend** APIs

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

## Development Methodology & Current State

**Current Phase: Production-Ready iOS App + Backend Development**
- **iOS**: Complete, production-ready application with sophisticated architecture
- **Backend**: Not yet created - this is our current development focus
- Ready for App Store submission once backend is connected

**Completed iOS Development:**
1. ✅ **Foundation**: Advanced architecture with dependency injection, error handling, logging
2. ✅ **Onboarding**: Complete 3-screen user setup with form validation and permissions
3. ✅ **Navigation**: Sophisticated 5-tab structure with consistent branding
4. ✅ **Voice Capture**: Real iOS Speech Recognition with visual feedback and haptic response
5. ✅ **Task Management**: Complete review flow with card UI, swipe gestures, bulk actions
6. ✅ **UI Polish**: Professional design with SF Symbols, animations, material backgrounds
7. ✅ **Production Features**: Offline support, caching, network monitoring, secure storage

**Next Phase Principles:**
- iOS development is complete - focus entirely on backend
- Create API endpoints that match existing iOS service protocols
- Build backend to support the sophisticated iOS app we already have
- Test end-to-end integration between complete iOS app and new backend
- "The iOS app is ready for production" - build backend to match its sophistication

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