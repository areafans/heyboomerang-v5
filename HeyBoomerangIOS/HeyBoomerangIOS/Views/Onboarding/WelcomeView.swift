//
//  WelcomeView.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var showOnboarding: Bool
    let onStartSetup: () -> Void
    @State private var currentStep = 0
    
    private let features = [
        (icon: "mic.fill", title: "Voice-First Capture", description: "Capture tasks hands-free while working with clients"),
        (icon: "brain.head.profile", title: "AI Task Generation", description: "Turn voice notes into actionable follow-ups automatically"),
        (icon: "paperplane.fill", title: "Automated Execution", description: "Send messages via SMS and email with one tap")
    ]
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Brand Area
            VStack(spacing: 16) {
                Text("Boomerang")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Transform voice notes into business growth")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // Feature Carousel
            VStack(spacing: 24) {
                let feature = features[currentStep]
                
                Image(systemName: feature.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text(feature.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(feature.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .frame(height: 200)
            .animation(.easeInOut, value: currentStep)
            
            // Page Indicators
            HStack(spacing: 8) {
                ForEach(0..<features.count, id: \.self) { index in
                    Circle()
                        .fill(currentStep == index ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: currentStep)
                }
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 16) {
                Button("Get Started") {
                    onStartSetup()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                
                Button("I'm already set up") {
                    // Skip to main app
                    showOnboarding = false
                }
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
        .onAppear {
            startFeatureCarousel()
        }
    }
    
    private func startFeatureCarousel() {
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            withAnimation(.easeInOut) {
                currentStep = (currentStep + 1) % features.count
            }
        }
    }
}

#Preview {
    WelcomeView(showOnboarding: .constant(true), onStartSetup: {})
}