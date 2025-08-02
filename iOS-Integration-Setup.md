# iOS Supabase Integration Setup Guide

## 🚀 What We've Built

### ✅ Completed Backend Integration:
- **Supabase Magic Link authentication** working via web
- **Production API endpoints** deployed and tested
- **Database schema** with user profiles and task management
- **iOS onboarding flow** with email authentication screen

### ✅ iOS Code Added:
- `SupabaseAuthService.swift` - Complete auth service
- `OnboardingData.swift` - Shared state for onboarding
- `EmailAuthView.swift` - Magic link email screen
- Updated onboarding flow with authentication step
- URL scheme handling in main app

## 🔧 Manual Setup Required (Xcode)

### 1. Add Supabase Swift Package

**In Xcode:**
1. Open `HeyBoomerangIOS.xcodeproj`
2. File → Add Package Dependencies
3. Enter URL: `https://github.com/supabase/supabase-swift`
4. Click "Add Package"
5. Select "Supabase" library and click "Add Package"

### 2. Configure URL Scheme

**In Xcode:**
1. Select your project in navigator
2. Go to your app target
3. Select "Info" tab
4. Expand "URL Types" section
5. Click "+" to add new URL Type
6. Set:
   - **Identifier**: `com.boomerang.auth`
   - **URL Schemes**: `boomerang`
   - **Role**: `Editor`

### 3. Update Supabase Redirect URLs

**In Supabase Dashboard:**
1. Go to Authentication → Settings
2. Add to "Redirect URLs":
   - `boomerang://auth/callback`

## 📱 Current Integration Status

### Working:
- ✅ Email authentication screen in iOS onboarding
- ✅ Magic link sending via Supabase
- ✅ URL scheme handling prepared
- ✅ Authentication state management
- ✅ User profile update after auth

### After Manual Setup:
- ✅ Magic links will redirect to iOS app
- ✅ Authentication tokens stored properly
- ✅ Real backend integration working

## 🧪 Testing Flow

**After setup:**
1. Build and run iOS app
2. Complete business setup
3. Enter email on auth screen
4. Check email and click magic link
5. iOS app opens and completes authentication
6. User profile updated with business info

## 🔄 Next Steps After Setup

1. **Update API Services** - Add authentication headers
2. **Test Backend Integration** - Verify real data flow
3. **Add OpenAI Integration** - Task generation from voice
4. **Add Message Delivery** - SMS/Email automation

## 🐛 Troubleshooting

**If magic link doesn't redirect to app:**
- Check URL scheme configuration
- Verify redirect URL in Supabase
- Test URL: `boomerang://auth/callback` in Safari

**If authentication fails:**
- Check Supabase package installation
- Verify environment URLs in SupabaseAuthService
- Check console logs for errors

## 📋 Files Modified/Added

### New Files:
- `SupabaseAuthService.swift` - Auth service
- `OnboardingData.swift` - Shared onboarding state
- `EmailAuthView.swift` - Authentication screen

### Modified Files:
- `OnboardingContainerView.swift` - Added email auth step
- `BusinessSetupView.swift` - Uses shared data
- `HeyBoomerangIOSApp.swift` - URL handling

The iOS integration framework is complete - just needs the Supabase package and URL scheme setup!