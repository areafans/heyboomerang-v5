//
//  MainView.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import SwiftUI

struct MainView: View {
    @StateObject private var voiceService = VoiceCaptureService()
    @State private var showingReview = false
    @State private var dailyCaptureCount = 7
    private let maxDailyCaptures = 32
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Today's Summary Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's Summary")
                        .font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("12 tasks ready")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("3 need contact info")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Review") {
                            showingReview = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
                
                // Voice Capture Button
                VStack(spacing: 16) {
                    Button(action: {
                        if voiceService.isRecording {
                            voiceService.stopRecording()
                        } else {
                            startRecording()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(voiceService.isRecording ? Color.red : Color.blue)
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: voiceService.isRecording ? "stop.fill" : "mic.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                    }
                    .scaleEffect(voiceService.isRecording ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: voiceService.isRecording)
                    
                    // Capture Counter
                    Text("\(dailyCaptureCount)/\(maxDailyCaptures)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Transcription Preview
                    if !voiceService.transcription.isEmpty {
                        Text(voiceService.transcription)
                            .font(.body)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .transition(.opacity)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Boomerang")
            .sheet(isPresented: $showingReview) {
                TaskReviewView()
            }
        }
    }
    
    private func startRecording() {
        voiceService.startRecording()
    }
}

#Preview {
    MainView()
}