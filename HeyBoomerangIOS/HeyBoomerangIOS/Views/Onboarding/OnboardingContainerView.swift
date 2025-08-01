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
    @State private var permissionsCompleted = false
    
    enum OnboardingScreen {
        case welcome
        case businessSetup
        case permissions
        case tutorial
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
                    BusinessSetupView(isCompleted: $businessSetupCompleted)
                        .onChange(of: businessSetupCompleted) { _, completed in
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
                                    currentScreen = .tutorial
                                }
                            }
                        }
                
                case .tutorial:
                    TutorialView(showOnboarding: $showOnboarding)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

// Simple tutorial view
struct TutorialView: View {
    @Binding var showOnboarding: Bool
    @State private var currentTip = 0
    
    private let tips = [
        (icon: "hand.tap.fill", title: "Press & Hold", description: "Press and hold the microphone button to capture voice notes"),
        (icon: "clock.fill", title: "Throughout Your Day", description: "Capture thoughts as they happen - no need to stop what you're doing"),
        (icon: "checkmark.circle.fill", title: "Review Each Evening", description: "We'll notify you when tasks are ready for review and approval")
    ]
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 16) {
                Text("How it works")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Get the most out of Boomerang with these tips")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // Current Tip
            VStack(spacing: 24) {
                let tip = tips[currentTip]
                
                Image(systemName: tip.icon)
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text(tip.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(tip.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .frame(height: 250)
            .animation(.easeInOut, value: currentTip)
            
            // Page Indicators
            HStack(spacing: 8) {
                ForEach(0..<tips.count, id: \.self) { index in
                    Circle()
                        .fill(currentTip == index ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: currentTip)
                }
            }
            
            Spacer()
            
            // Navigation
            VStack(spacing: 16) {
                if currentTip < tips.count - 1 {
                    Button("Next") {
                        withAnimation {
                            currentTip += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                } else {
                    Button("Start Using Boomerang") {
                        showOnboarding = false
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                }
                
                Button("Skip") {
                    showOnboarding = false
                }
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
        .padding(.top, 20)
    }
}

#Preview {
    OnboardingContainerView(showOnboarding: .constant(true))
}