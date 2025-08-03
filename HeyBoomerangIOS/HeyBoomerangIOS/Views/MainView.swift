//
//  VoiceCaptureView.swift (renamed from MainView.swift)
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import SwiftUI

struct VoiceCaptureView: View {
    @StateObject private var voiceService = DependencyContainer.shared.voiceCaptureService
    @StateObject private var apiService = DependencyContainer.shared.apiService
    @State private var showingReview = false
    @State private var dailyCaptureCount = 7
    @State private var pendingTasksCount = 12
    @State private var tasksNeedingInfo = 3
    @State private var isPressed = false
    @State private var isProcessing = false
    @State private var lastTranscription = ""
    private let maxDailyCaptures = 32
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                // Simple header for voice capture
                VStack(spacing: 8) {
                    Text("Voice Capture")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Tap the microphone to capture voice notes throughout your day")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Voice Capture Section
                VStack(spacing: 24) {
                    // Large Microphone Button
                    VStack(spacing: 16) {
                        ZStack {
                            // Outer ring for press feedback
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: isPressed ? 160 : 140, height: isPressed ? 160 : 140)
                                .animation(.easeInOut(duration: 0.1), value: isPressed)
                            
                            // Main button
                            Circle()
                                .fill(voiceService.isRecording ? 
                                     LinearGradient(colors: [.red, .red.opacity(0.8)], startPoint: .top, endPoint: .bottom) :
                                     LinearGradient(colors: [.blue, .blue.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                                .frame(width: 120, height: 120)
                                .shadow(color: voiceService.isRecording ? .red.opacity(0.3) : .blue.opacity(0.3), 
                                       radius: isPressed ? 12 : 8, x: 0, y: 4)
                            
                            Image(systemName: voiceService.isRecording ? "stop.fill" : "mic.fill")
                                .font(.system(size: 44, weight: .medium))
                                .foregroundColor(.white)
                                .symbolRenderingMode(.hierarchical)
                                .symbolEffect(.pulse, isActive: voiceService.isRecording)
                        }
                        .scaleEffect(isPressed ? 0.95 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: voiceService.isRecording)
                        .animation(.easeInOut(duration: 0.1), value: isPressed)
                        .onTapGesture {
                            // Toggle recording on/off
                            isPressed = true
                            
                            if voiceService.isRecording {
                                // Stop recording
                                Task {
                                    await stopRecordingAndProcess()
                                }
                            } else {
                                // Start recording
                                startRecording()
                            }
                            
                            // Reset pressed state after animation
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isPressed = false
                            }
                        }
                        .sensoryFeedback(.impact(flexibility: .soft), trigger: isPressed)
                        
                        // Instruction Text
                        Text(getStatusText())
                            .font(.subheadline)
                            .foregroundColor(getStatusColor())
                            .fontWeight(.medium)
                            .animation(.easeInOut, value: voiceService.isRecording)
                    }
                    
                    // Capture Counter (Subtle)
                    Text("\(dailyCaptureCount)/\(maxDailyCaptures)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .opacity(0.7)
                    
                    // Transcription Preview
                    if !voiceService.transcription.isEmpty {
                        VStack(spacing: 8) {
                            Text("Captured:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(voiceService.transcription)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding(16)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .transition(.opacity.combined(with: .scale))
                        }
                        .padding(.horizontal, 20)
                        .animation(.easeInOut(duration: 0.3), value: voiceService.transcription)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Boomerang")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.regularMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    private func startRecording() {
        Task {
            let result = await voiceService.startRecording()
            if case .failure(let error) = result {
                print("❌ Failed to start recording: \(error)")
            }
        }
    }
    
    private func stopRecordingAndProcess() async {
        isProcessing = true
        
        let result = await voiceService.stopRecording()
        
        switch result {
        case .success(let transcription):
            print("✅ Recording stopped successfully with transcription: '\(transcription)'")
            lastTranscription = transcription
            
            // Send transcription to backend for task processing
            if !transcription.isEmpty {
                await processTranscription(transcription)
            }
            
        case .failure(let error):
            print("❌ Failed to stop recording: \(error)")
        }
        
        isProcessing = false
    }
    
    private func processTranscription(_ transcription: String) async {
        print("🚀 Processing transcription: '\(transcription)'")
        
        let result = await apiService.submitCapture(transcription: transcription, duration: 5.0)
        
        switch result {
        case .success(let response):
            print("✅ Successfully submitted capture to backend")
            print("📝 Response: \(response.message)")
            
            if !response.tasksGenerated.isEmpty {
                print("🎯 Generated \(response.tasksGenerated.count) tasks")
            } else {
                print("ℹ️ No actionable tasks generated from this transcription")
            }
            
        case .failure(let error):
            print("❌ Failed to submit capture: \(error)")
        }
    }
    
    private func getStatusText() -> String {
        if isProcessing {
            return "Processing..."
        } else if voiceService.isRecording {
            return "Recording... Tap to stop"
        } else {
            return "Tap to start recording"
        }
    }
    
    private func getStatusColor() -> Color {
        if isProcessing {
            return .orange
        } else if voiceService.isRecording {
            return .red
        } else {
            return .secondary
        }
    }
}

#Preview {
    VoiceCaptureView()
}