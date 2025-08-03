//
//  OnboardingContainerView.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import SwiftUI

struct OnboardingContainerView: View {
    @Binding var showOnboarding: Bool
    @State private var currentScreen: OnboardingScreen = .welcome
    @State private var businessSetupCompleted = false
    @State private var emailAuthCompleted = false
    @State private var permissionsCompleted = false
    @StateObject private var onboardingData = OnboardingData()
    
    enum OnboardingScreen {
        case welcome
        case businessSetup
        case emailAuth
        case permissions
    }
    
    var body: some View {
        NavigationView {
            Group {
                switch currentScreen {
                case .welcome:
                    WelcomeView(showOnboarding: $showOnboarding) {
                        withAnimation {
                            currentScreen = .businessSetup
                        }
                    }
                
                case .businessSetup:
                    BusinessSetupView(isCompleted: $businessSetupCompleted, onboardingData: onboardingData)
                        .onChange(of: businessSetupCompleted) { _, completed in
                            if completed {
                                withAnimation {
                                    currentScreen = .emailAuth
                                }
                            }
                        }
                
                case .emailAuth:
                    EmailPasswordAuthView(isCompleted: $emailAuthCompleted, onboardingData: onboardingData)
                        .onChange(of: emailAuthCompleted) { _, completed in
                            if completed {
                                withAnimation {
                                    currentScreen = .permissions
                                }
                            }
                        }
                
                case .permissions:
                    PermissionsView(isCompleted: $permissionsCompleted)
                        .onChange(of: permissionsCompleted) { _, completed in
                            if completed {
                                withAnimation {
                                    showOnboarding = false
                                }
                            }
                        }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}


#Preview {
    OnboardingContainerView(showOnboarding: .constant(true))
}