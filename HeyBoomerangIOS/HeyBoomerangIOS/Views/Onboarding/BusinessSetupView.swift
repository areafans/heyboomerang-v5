//
//  BusinessSetupView.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import SwiftUI

struct BusinessSetupView: View {
    @Binding var isCompleted: Bool
    @State private var userName = ""
    @State private var businessName = ""
    @State private var businessDescription = ""
    @State private var currentStep = 0
    
    var body: some View {
        VStack(spacing: 30) {
            // Progress Indicator
            HStack {
                ForEach(0..<3, id: \.self) { step in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                        .frame(height: 4)
                        .animation(.easeInOut, value: currentStep)
                }
            }
            .padding(.horizontal)
            
            // Header
            VStack(spacing: 16) {
                Text("Set up your business")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("This helps us personalize your experience and generate better follow-ups")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // Form Steps
            Group {
                switch currentStep {
                case 0:
                    userNameStep
                case 1:
                    businessNameStep
                case 2:
                    businessDescriptionStep
                default:
                    EmptyView()
                }
            }
            .animation(.easeInOut, value: currentStep)
            
            Spacer()
            
            // Navigation Buttons
            HStack(spacing: 16) {
                if currentStep > 0 {
                    Button("Back") {
                        withAnimation {
                            currentStep -= 1
                        }
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                }
                
                Button(currentStep == 2 ? "Complete Setup" : "Continue") {
                    if currentStep == 2 {
                        completeSetup()
                    } else {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .disabled(!canContinue)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
        .padding(.top, 20)
    }
    
    private var userNameStep: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            VStack(spacing: 16) {
                Text("What's your name?")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                TextField("Your name", text: $userName)
                    .textFieldStyle(.roundedBorder)
                    .font(.title3)
                    .padding(.horizontal, 32)
            }
        }
    }
    
    private var businessNameStep: some View {
        VStack(spacing: 24) {
            Image(systemName: "storefront.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            VStack(spacing: 16) {
                Text("What's the name of your business, \(userName)?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                TextField("Business name", text: $businessName)
                    .textFieldStyle(.roundedBorder)
                    .font(.title3)
                    .padding(.horizontal, 32)
            }
        }
    }
    
    private var businessDescriptionStep: some View {
        VStack(spacing: 24) {
            Image(systemName: "text.bubble.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            VStack(spacing: 16) {
                Text("Will you describe \(businessName)?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("Tell us what you do - we'll use this to personalize your experience")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                TextField("e.g., We're a general contracting company specializing in home renovations and kitchen remodels", text: $businessDescription, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
                    .padding(.horizontal, 32)
            }
        }
    }
    
    private var canContinue: Bool {
        switch currentStep {
        case 0: return !userName.isEmpty
        case 1: return !businessName.isEmpty
        case 2: return !businessDescription.isEmpty
        default: return false
        }
    }
    
    private func completeSetup() {
        // Mock saving business data
        print("Business Setup Complete:")
        print("User: \(userName)")
        print("Business: \(businessName)")
        print("Description: \(businessDescription)")
        
        withAnimation {
            isCompleted = true
        }
    }
}

#Preview {
    BusinessSetupView(isCompleted: .constant(false))
}