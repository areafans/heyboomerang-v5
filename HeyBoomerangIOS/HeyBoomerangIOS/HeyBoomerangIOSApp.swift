//
//  HeyBoomerangIOSApp.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//  Refactored by Claude on 8/2/25.
//

import SwiftUI

@main
struct HeyBoomerangIOSApp: App {
    // Initialize dependency container
    @StateObject private var dependencyContainer = DependencyContainer.shared
    // Initialize Supabase auth service
    @StateObject private var authService = SupabaseAuthService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dependencyContainer)
                .environmentObject(authService)
                .task {
                    await initializeApp()
                }
                // Removed URL handling since we're using email/password auth
        }
    }
    
    // Removed URL handling methods since we're using email/password auth
    
    // MARK: - App Initialization
    
    private func initializeApp() async {
        await Logger.shared.info("HeyBoomerang iOS app starting up", category: .general)
        
        // Perform any startup tasks
        await setupAppearance()
        await performStartupChecks()
    }
    
    private func setupAppearance() async {
        await Logger.shared.debug("Setting up app appearance", category: .ui)
        
        // Configure global UI appearance
        await MainActor.run {
            // Set up navigation bar appearance
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
            navBarAppearance.shadowColor = UIColor.separator.withAlphaComponent(0.3)
            
            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().compactAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
            
            // Set up tab bar appearance
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
            
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
    
    private func performStartupChecks() async {
        await Logger.shared.debug("Performing startup checks", category: .general)
        
        // Check for critical permissions
        let voiceService = dependencyContainer.voiceCaptureService
        let permissionResult = await voiceService.requestPermissions()
        
        switch permissionResult {
        case .success(let granted):
            await Logger.shared.info("Voice permissions granted: \(granted)", category: .general)
        case .failure(let error):
            await Logger.shared.warning("Voice permissions not granted: \(error.localizedDescription)", category: .general)
        }
        
        // Log app version and build info
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            await Logger.shared.info("App version: \(version) (\(build))", category: .general)
        }
    }
}
