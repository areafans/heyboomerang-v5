//
//  BusinessSetupView.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import SwiftUI

struct BusinessSetupView: View {
    @Binding var isCompleted: Bool
    @State private var businessName = ""
    @State private var businessType = ""
    @State private var city = ""
    @State private var state = ""
    @State private var currentStep = 0
    
    private let businessTypes = [
        "Hair Salon", "Barbershop", "Spa & Wellness", "Personal Training",
        "Home Services", "Contractor", "Restaurant", "Dental Practice",
        "Auto Shop", "Consulting", "Other"
    ]
    
    private let states = [
        "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
        "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
        "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
        "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
        "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"
    ]
    
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
                    businessNameStep
                case 1:
                    businessTypeStep
                case 2:
                    locationStep
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
    
    private var businessNameStep: some View {
        VStack(spacing: 24) {
            Image(systemName: "storefront.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            VStack(spacing: 16) {
                Text("What's your business name?")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                TextField("Business name", text: $businessName)
                    .textFieldStyle(.roundedBorder)
                    .font(.title3)
                    .padding(.horizontal, 32)
            }
        }
    }
    
    private var businessTypeStep: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            VStack(spacing: 16) {
                Text("What type of business?")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Menu {
                    ForEach(businessTypes, id: \.self) { type in
                        Button(type) {
                            businessType = type
                        }
                    }
                } label: {
                    HStack {
                        Text(businessType.isEmpty ? "Select business type" : businessType)
                            .foregroundColor(businessType.isEmpty ? .secondary : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 32)
                }
            }
        }
    }
    
    private var locationStep: some View {
        VStack(spacing: 24) {
            Image(systemName: "location.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            VStack(spacing: 16) {
                Text("Where are you located?")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(spacing: 12) {
                    TextField("City", text: $city)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 32)
                    
                    Menu {
                        ForEach(states, id: \.self) { stateCode in
                            Button(stateCode) {
                                state = stateCode
                            }
                        }
                    } label: {
                        HStack {
                            Text(state.isEmpty ? "State" : state)
                                .foregroundColor(state.isEmpty ? .secondary : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal, 32)
                    }
                }
            }
        }
    }
    
    private var canContinue: Bool {
        switch currentStep {
        case 0: return !businessName.isEmpty
        case 1: return !businessType.isEmpty
        case 2: return !city.isEmpty && !state.isEmpty
        default: return false
        }
    }
    
    private func completeSetup() {
        // Mock saving business data
        print("Business Setup Complete:")
        print("Name: \(businessName)")
        print("Type: \(businessType)")
        print("Location: \(city), \(state)")
        
        withAnimation {
            isCompleted = true
        }
    }
}

#Preview {
    BusinessSetupView(isCompleted: .constant(false))
}