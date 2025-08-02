//
//  ContentView.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//  Refactored by Claude on 8/2/25.
//

import SwiftUI

struct ContentView: View {
    private var userService: any UserServiceProtocol {
        DependencyContainer.shared.resolve(any UserServiceProtocol.self)
    }
    @State private var showOnboarding = true
    @State private var isInitialized = false
    
    var body: some View {
        Group {
            if !isInitialized {
                // Show loading screen while determining app state
                LoadingView()
            } else if showOnboarding {
                OnboardingContainerView(showOnboarding: $showOnboarding)
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showOnboarding)
        .animation(.easeInOut(duration: 0.3), value: isInitialized)
        .task {
            await initializeAppState()
        }
        .onChange(of: userService.isAuthenticated) { _, isAuthenticated in
            withAnimation {
                showOnboarding = !isAuthenticated || !userService.isOnboardingCompleted()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func initializeAppState() async {
        await Logger.shared.info("Initializing app state", category: .ui)
        
        // Get current user and determine onboarding state
        let userResult = await userService.getCurrentUser()
        
        switch userResult {
        case .success(let user):
            let hasCompletedOnboarding = userService.isOnboardingCompleted()
            
            await MainActor.run {
                showOnboarding = user == nil || !hasCompletedOnboarding
                isInitialized = true
            }
            
            await Logger.shared.info("App state initialized - Show onboarding: \(showOnboarding)", category: .ui)
            
        case .failure(let error):
            await Logger.shared.error("Failed to initialize app state", error: error, category: .ui)
            
            // Default to showing onboarding on error
            await MainActor.run {
                showOnboarding = true
                isInitialized = true
            }
        }
    }
}

// MARK: - Loading View

private struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(1.5)
            
            Text("Loading...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    ContentView()
}
