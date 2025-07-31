//
//  VoiceCaptureService.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import Foundation

class VoiceCaptureService: ObservableObject {
    @Published var isRecording = false
    @Published var transcription = ""
    
    private var recordingTimer: Timer?
    private let mockTranscriptions = [
        "Just finished with Mary Johnson",
        "Need to order more shampoo for next week",
        "Having a great day with clients",
        "Sarah Williams loved her new haircut",
        "Remember to follow up with the new client tomorrow"
    ]
    
    func startRecording() {
        isRecording = true
        transcription = ""
        
        // Simulate recording for 2-3 seconds
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { _ in
            self.stopRecording()
        }
    }
    
    func stopRecording() {
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        // Add mock transcription
        if let randomTranscription = mockTranscriptions.randomElement() {
            transcription = randomTranscription
        }
    }
}