//
//  VoiceCaptureView.swift (renamed from MainView.swift)
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import SwiftUI

struct VoiceCaptureView: View {
    @StateObject private var voiceService = VoiceCaptureService()
    @State private var showingReview = false
    @State private var dailyCaptureCount = 7
    @State private var pendingTasksCount = 12
    @State private var tasksNeedingInfo = 3
    @State private var isPressed = false
    private let maxDailyCaptures = 32
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                // Simple header for voice capture
                VStack(spacing: 8) {
                    Text("Voice Capture")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Hold the microphone to capture voice notes throughout your day")
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
                        .scaleEffect(voiceService.isRecording ? 1.05 : (isPressed ? 0.95 : 1.0))
                        .animation(.easeInOut(duration: 0.1), value: voiceService.isRecording)
                        .animation(.easeInOut(duration: 0.1), value: isPressed)
                        .onLongPressGesture(minimumDuration: 0.1, maximumDistance: 50) {
                            // Long press completed
                            voiceService.stopRecording()
                            isPressed = false
                        } onPressingChanged: { pressing in
                            if pressing {
                                isPressed = true
                                startRecording()
                            } else if voiceService.isRecording {
                                voiceService.stopRecording()
                                isPressed = false
                            }
                        }
                        .sensoryFeedback(.impact(flexibility: .soft), trigger: isPressed)
                        
                        // Instruction Text
                        Text(voiceService.isRecording ? "Recording... Release to stop" : "Hold to capture")
                            .font(.subheadline)
                            .foregroundColor(voiceService.isRecording ? .red : .secondary)
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
            .navigationTitle("Capture")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func startRecording() {
        voiceService.startRecording()
    }
}

#Preview {
    VoiceCaptureView()
}