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
        "Just finished the kitchen demo at the Johnson house",
        "Need to order drywall for the Williams project next week",
        "Having a great day on the renovation sites",
        "The Smiths are really happy with their new bathroom",
        "Remember to follow up with the Miller family about their deck project"
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