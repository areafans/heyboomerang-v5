# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 📋 **MUST READ: Complete Project Documentation**

**For comprehensive project details, architecture, and requirements, see:**
- **[boomerang-v5-prd.md](./boomerang-v5-prd.md)** - Complete Product Requirements Document
- This CLAUDE.md file - Development guidance and current status

## 🚨 CRITICAL: Current Project Status (Updated August 2025)

**IMPORTANT: The iOS app is essentially COMPLETE and production-ready.** This is NOT an early prototype - it's a sophisticated, mature iOS application with 39+ Swift files, complete user flows, and advanced architecture.

**BEFORE starting any work:**
1. **Read the PRD document** (`boomerang-v5-prd.md`) to understand the full product vision
2. **Read the Current State section below** to understand we have a complete iOS app
3. **Focus on backend development** - that's the primary gap, not iOS features
4. **Update todo status** only when you complete actual work
5. **DO NOT assume iOS features are missing** - they're likely already implemented

**Key Insight: We're in "Production iOS App Needs Backend" phase, not early development.**

## 🎯 **What Boomerang Actually Does** (For New Developers)

**Boomerang is a voice-first iOS app for small service businesses** that transforms voice notes into automated business tasks:

### **Core User Journey**:
```
Throughout Day: "Remind me to call John" → AI processes → Creates task
Evening: User reviews tasks → Swipes to approve → App executes automatically
Next Morning: See results → "SMS sent to John about project update"
```

### **Key Business Value**:
- **Input**: Stream-of-consciousness voice notes during work
- **Process**: AI converts to structured business actions using context
- **Output**: Automated follow-ups, reminders, SMS, emails, calls
- **Result**: Business growth through consistent communication

### **NOT a simple voice memo app** - it's an AI-powered business automation system that happens to use voice as the input method.

## 🚀 Quick Start for New Developers

**If you're new to this project:**

1. **Read [boomerang-v5-prd.md](./boomerang-v5-prd.md)** - Essential for understanding the product
2. **Open `HeyBoomerangIOS.xcodeproj` in Xcode** - the iOS app is complete and ready
3. **Build and run** - everything works with mock data and real voice capture
4. **The iOS app is production-ready** - 39+ Swift files, sophisticated architecture
5. **Focus on backend development** - that's what's missing, not iOS features
6. **Don't rebuild iOS features** - they're already implemented and polished

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

## 🔧 **CRITICAL: AI Function Calling Architecture** (Implementation Details)

**🚨 IMPORTANT: Boomerang uses OpenAI Function Calling, NOT simple text generation**

### **How Voice-to-Task Processing Actually Works**:

```
Voice: "Remind me to call John about his project"
↓
iOS Speech Recognition: Converts to text
↓
Backend /api/capture: Sends to OpenAI with 6 specialized functions
↓
OpenAI: Calls create_reminder() function with structured parameters
↓
Database: Creates task with task_type='reminder', timing='tomorrow'
↓
iOS Tasks Tab: User sees "Call John about his project" for evening review
↓
User Approves: Task executes automatically (call reminder set)
```

### **6 Specialized OpenAI Functions** (All Generate Tasks for Review):

1. **`create_contact`** - "Create a contact for Mike Smith"
   - Creates `task_type='create_contact'` for user review
   - When approved: Actually creates contact in database

2. **`send_sms`** - "Text John about his appointment"
   - Creates `task_type='send_sms'` for user review
   - When approved: Sends SMS via Twilio

3. **`send_email`** - "Email Mary about project update"
   - Creates `task_type='send_email'` for user review
   - When approved: Sends email via SendGrid

4. **`create_reminder`** - "Remind me to order drywall"
   - Creates `task_type='reminder'` for user review
   - When approved: Sets internal reminder/notification

5. **`make_phone_call`** - "Call Sarah about pricing"
   - Creates `task_type='make_phone_call'` for user review
   - When approved: Triggers external calling app

6. **`create_note`** - "Note that we need more supplies"
   - Creates `task_type='create_note'` for user review
   - When approved: Saves business note for future reference

### **Key Architectural Principles**:

- **All tasks go to review queue first** - Nothing executes immediately
- **Evening review workflow** - User approves/skips tasks before execution
- **Context learning** - AI gets smarter based on user approval patterns
- **Multi-tenancy** - Each user's AI context is completely isolated
- **Safety first** - User always has final control over all actions

### **NOT Simple Text Generation**:
❌ "Generate a task list from this voice note"
✅ "Call the appropriate function to create the right business task"

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
- **4-screen onboarding flow**: Welcome → Business Setup → Email/Password Auth → Permissions
- **5-tab navigation**: Summary | Tasks | Capture | Dashboard | Profile  
- **Advanced voice capture**: Both mock (development) and real (production) Speech framework
- **Sophisticated task review**: Card-based UI with swipe gestures
- **Rich animations**: Haptic feedback, spring animations, visual transitions
- **Professional UI polish**: SF Symbols, consistent spacing, material backgrounds
- **Complete authentication**: Email/password auth with Supabase integration

**✅ Advanced Features Already Implemented:**
- **TaskReviewFlow.swift**: Complete 5-step review process (Group Summary, Contact Disambiguation, Contact Details, Timing Selection, Message Preview)
- **VoiceCaptureService**: Real iOS Speech Recognition with permission handling
- **TaskCardStackView**: Swipe navigation, progress indicators, bulk actions
- **Contact management**: Disambiguation, validation, CRUD operations
- **Error handling**: Comprehensive AppError system with user-friendly messages
- **Offline support**: Caching, data persistence, network monitoring
- **Authentication system**: Complete Supabase email/password auth with profile creation
- **Real data integration**: UserService automatically fetches and displays real user data

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
│   ├── UserService.swift - Profile management with real backend integration
│   ├── SupabaseAuthService.swift - Complete email/password authentication
│   ├── APIService.swift - Network layer with authentication headers
│   └── NetworkManager.swift - Advanced HTTP client with monitoring
├── Views/
│   ├── Onboarding/ - 4-screen setup flow (includes email/password auth)
│   ├── Tabs/ - 5-tab navigation structure with real data integration
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

### **WHAT WE NEED (Backend - PARTIALLY IMPLEMENTED)**

**✅ COMPLETED Backend Infrastructure:**
- ✅ Vercel + Next.js API deployed and functional
- ✅ Supabase database configured with users table and RLS
- ✅ User authentication system (email/password with Supabase)
- ✅ User profile API endpoint (`/api/user/profile`) with GET/POST/PUT support

**❌ MISSING Backend Features:**
- ❌ Task processing endpoints (`/api/capture`, `/api/tasks/pending`)
- ❌ Contact management APIs
- ❌ Message scheduling and tracking systems

**❌ AI Integration:**
- ❌ OpenAI API integration for task generation from voice transcriptions
- ❌ User context learning system for personalized messages
- ❌ Contact matching and message personalization algorithms

**❌ Message Delivery:**
- ❌ Twilio SMS integration for automated message sending
- ❌ SendGrid email integration for email communications
- ❌ Delivery tracking and webhook handling for status updates

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

## 🧠 **Context & Learning System** (Planned Implementation)

**The app will maintain intelligent, user-specific context that gets smarter over time:**

### **Learning Sources**:
- **Business Context**: Name, type, location, messaging style from user profile
- **Message Examples**: Last 20 approved messages for style learning
- **Contact Patterns**: Interaction history and preferences per contact
- **Timing Preferences**: When user prefers to send different types of messages
- **Approval Patterns**: What types of tasks user approves vs skips

### **How Context Gets Applied**:
```javascript
// Example: AI learns user's communication style
const userContext = {
  businessType: "hair_salon",
  messageStyle: "friendly_professional", // Learned from approvals
  preferredTiming: "end_of_day", // User usually approves evening sends
  recentApprovals: ["Great haircut today! Let me know if you need a touch-up"]
}

// OpenAI uses this context to generate better tasks
const aiPrompt = `You help ${userContext.businessType} owner.
Style: ${userContext.messageStyle}
Recent approved messages: ${userContext.recentApprovals.join('; ')}`
```

### **Multi-Tenancy & Privacy**:
- **Each user's context is completely isolated** - no data sharing between accounts
- **Context builds only from that user's actions** - approvals, skips, edits
- **Easy export/deletion** - full user data control and GDPR compliance

### **Database Tables** (To Be Created):
- `user_context` - Business info, message style examples, learned preferences
- `contact_insights` - Per-contact interaction patterns and success rates
- `pattern_analytics` - Usage patterns, timing preferences, task success rates

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
✅ 4-screen onboarding flow (Welcome → Business Setup → Email/Password Auth → Permissions)
✅ 5-tab navigation (Summary | Tasks | Capture | Dashboard | Profile)
✅ Advanced voice capture with real iOS Speech Recognition
✅ Sophisticated task review with TaskCardStackView and swipe gestures
✅ Professional UI polish with SF Symbols, animations, haptic feedback
✅ Pull-to-refresh, loading states, empty states
✅ Complete authentication flow with real user data integration

**Advanced Features Implemented:**
✅ TaskReviewFlow.swift with complete 5-step process
✅ Real VoiceCaptureService with iOS Speech framework
✅ Contact disambiguation and management
✅ Task approval/skip with bulk actions
✅ Network monitoring and offline support
✅ Comprehensive error handling and user messaging
✅ Complete Supabase authentication system with email/password
✅ Real user data integration - no more mock data throughout the app

### **🚧 BACKEND INFRASTRUCTURE (Current Development Phase)**

**✅ COMPLETED Backend Features:**
✅ **B1.1** Set up Vercel project and Next.js API structure
✅ **B1.2** Configure Supabase database with proper schema
✅ **B1.3** Implement user authentication (email/password with Supabase)
✅ **B1.4** Create user profile API endpoints matching iOS service protocols
✅ **B1.5** Set up environment variables and deployment
✅ **B1.6** Create task processing API endpoints (`/api/capture`, `/api/tasks/pending`)
✅ **B2.1** Integrate OpenAI API with **6 specialized functions** for task generation

**🎯 MAJOR BREAKTHROUGH: OpenAI Function Calling System OPERATIONAL (August 2025)**

**✅ SYSTEM STATUS: FULLY FUNCTIONAL END-TO-END** 🚀

The complete OpenAI Function Calling system is now working from voice input to task display:

**✅ 6 Specialized AI Functions Operational:**
- `create_contact` - CRUD operations for contacts (customers, leads, vendors)
- `send_sms` - SMS message tasks with contact resolution
- `send_email` - Email communication tasks with subject/body generation  
- `create_reminder` - Personal reminders/todos for business owner
- `make_phone_call` - Phone call reminder tasks with purpose
- `create_note` - Business note creation with tagging

**✅ Complete Data Flow Working:**
```
Voice: "Remind me to order drywall" 
→ Speech Recognition
→ OpenAI Function Call: create_reminder(task: "Order drywall", timing: "tomorrow")  
→ Database Storage: task_type='reminder', message='Order drywall'
→ iOS Display: Blue bell icon "Reminder" task in Tasks tab
→ User Review: Swipe to approve → Execution (future: actual reminder delivery)
```

**✅ Technical Victories Achieved:**
- Fixed all JSON decoding issues (TasksResponse date parsing was root cause)
- Implemented proper task type semantics (`reminder` vs `reminder_call`)
- Resolved database constraint violations with schema migrations
- Eliminated SwiftUI threading warnings with proper MainActor usage
- Created robust error handling with detailed logging for debugging

**✅ Current Verification**: App shows "9 tasks ready for review" with proper categorization

**🚨 PRIORITY ISSUE TO ADDRESS NEXT:**

**⚠️ Speech Recognition Error Logging**
- **Issue**: Systematic scrolling errors in console: `Error Domain=kAFAssistantErrorDomain Code=1101`  
- **Impact**: Core functionality works, but indicates potential stability issues
- **Status**: Errors are filtered as "spurious iOS 17+ errors" but still appearing
- **Priority**: Medium - Should investigate for production stability
- **Investigation Areas**:
  - Multiple speech recognition tasks running simultaneously
  - Cleanup timing issues between recording sessions  
  - iOS 17+ speech recognition initialization sequence

**❌ REMAINING Backend Features (Lower Priority):**
❌ **Context & Learning System**: User-specific AI personalization with context learning
❌ **Contact Disambiguation**: Smart contact matching and resolution logic  
❌ **Message Delivery**: Twilio SMS + SendGrid email integration for task execution
❌ **Production Features**: API monitoring, subscription system, payment processing
❌ **Business Intelligence**: Analytics, usage tracking, performance optimization

## 🔧 **SESSION ACCOMPLISHMENTS & KEY INSIGHTS**

**Major Breakthrough Achieved**: Complete OpenAI Function Calling system operational end-to-end

**Critical Technical Insights Discovered:**
1. **JSON Decoding Root Cause**: Backend sending `lastSyncedAt` as string, iOS expecting Date object
2. **Task Type Semantics**: Need distinction between `reminder` (general) vs `reminder_call` (phone)  
3. **Database Constraint Issues**: Required schema migrations for new task types
4. **SwiftUI Threading**: All @Published updates must use `MainActor.run` to avoid purple warnings
5. **Error Handling Strategy**: Robust decoders with fallbacks prevent total decode failures

**Architecture Decisions Made:**
- OpenAI Function Calling with 6 specialized functions vs single generic function
- Task types map to specific iOS TaskType enum values for UI consistency
- Custom Codable implementations handle backend/frontend data format differences
- Separation of general reminders from call reminders for better UX

**Files Modified This Session:**
- `pages/api/capture.ts` - OpenAI function calling implementation
- `pages/api/tasks/pending.ts` - Task retrieval with proper data formatting
- `HeyBoomerangIOS/.../Models/Task.swift` - Enhanced TaskType enum + custom Codable
- `HeyBoomerangIOS/.../Services/APIService.swift` - TasksResponse date decoding fix
- `HeyBoomerangIOS/.../Services/VoiceCaptureService.swift` - Threading issue fixes
- `supabase/schema.sql` + migrations - Database constraint updates

**Next Session Priorities:**
1. **HIGH**: Investigate and fix speech recognition error logging issue  
2. **MEDIUM**: Implement context learning system for AI personalization
3. **MEDIUM**: Add Twilio/SendGrid integrations for actual message delivery
4. **LOW**: Build contact disambiguation and matching logic

**Development Notes for Next Session:**
- The core system is working - focus on stability and enhancement vs foundational fixes
- All major JSON/decoding issues have been resolved through custom Codable implementations  
- Database schema is current and supports all 6 OpenAI function types
- iOS app is production-ready and requires no additional core features
❌ **B4.3** Add usage analytics and business intelligence
❌ **B4.4** Performance optimization and caching
❌ **B4.5** Security audit and deployment preparation

### **🎯 IMMEDIATE PRIORITIES** (Next Development Steps)

**✅ MAJOR BREAKTHROUGH COMPLETE**: OpenAI Function Calling Architecture Implemented

**📋 CURRENT TESTING PHASE:**
1. **Test simple reminder tasks first** - "Remind me to order drywall" 
2. **Update database schema** - Add new task_type values to support all 6 functions
3. **Test each function type individually** - Verify all 6 OpenAI functions work correctly
4. **Implement context learning system** - Make AI smarter over time

**🚧 NEXT DEVELOPMENT PRIORITIES:**
1. **Database Schema Update** - Support create_contact, send_sms, send_email, make_phone_call, create_note
2. **Context Learning System** - User-specific AI that gets smarter from approvals  
3. **Contact Disambiguation** - Resolve "John" to specific contact for SMS/email tasks
4. **External Integrations** - Twilio (SMS), SendGrid (email) for approved task execution
5. **Task Execution System** - Actually perform approved tasks (create contacts, send messages)

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

**Data Strategy:**
- ✅ **Real User Data**: Authentication working, users see their actual business information
- ✅ **Profile Integration**: UserService automatically fetches and displays real user profiles
- ❌ **Task Processing**: Still needs backend endpoints for voice-to-task conversion
- ❌ **Message Delivery**: No SMS/email integration yet
- **Empty States**: App shows proper empty states while waiting for backend features

**Navigation Structure:**
- **Onboarding**: Welcome → Business Setup (name/business/description) → Email/Password Auth → Permissions
- **Main App Tabs**: Summary (morning results) | Tasks (evening review) | Capture (center) | Dashboard (metrics) | Profile (settings)
- **Key UX**: Morning check summary → All day capture → Evening review tasks
- **Authentication**: Complete email/password flow with automatic profile creation

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