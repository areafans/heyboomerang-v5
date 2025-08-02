//
//  VoiceCaptureService.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//  Refactored by Claude on 8/2/25.
//

import Foundation
import AVFoundation
import Speech
import SwiftUI

// MARK: - Modern Voice Capture Service with iOS 17+ @Observable

final class VoiceCaptureService: NSObject, VoiceCaptureServiceProtocol, ObservableObject, @unchecked Sendable {
    // Observable properties
    @Published var isRecording = false
    @Published var transcription = ""
    @Published var currentError: AppError?
    
    // Private properties
    private var audioEngine: AVAudioEngine?
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recordingTimer: Timer?
    
    private let configuration: AppConfigurationProtocol
    
    // Mock data for prototype phase
    private let mockTranscriptions = [
        "Just finished the kitchen demo at the Johnson house",
        "Need to order drywall for the Williams project next week",
        "Having a great day on the renovation sites",
        "The Smiths are really happy with their new bathroom",
        "Remember to follow up with the Miller family about their deck project",
        "Client wants to upgrade to granite countertops",
        "Plumber is coming tomorrow morning at 9 AM",
        "Invoice for the Thompson project is ready to send",
        "Weather looks good for the outdoor deck installation",
        "Need to order more tile for the bathroom renovation"
    ]
    
    init(configuration: AppConfigurationProtocol? = nil) {
        self.configuration = configuration ?? AppConfiguration()
        super.init()
        setupSpeechRecognition()
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - Public Interface
    
    // MARK: - Permission Checking (non-requesting)
    
    func checkPermissions() async -> Bool {
        let micStatus: Bool
        if #available(iOS 17.0, *) {
            micStatus = AVAudioApplication.shared.recordPermission == .granted
        } else {
            micStatus = AVAudioSession.sharedInstance().recordPermission == .granted
        }
        
        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        
        return micStatus && speechStatus == .authorized
    }
    
    func getMicrophonePermissionStatus() -> Bool {
        if #available(iOS 17.0, *) {
            return AVAudioApplication.shared.recordPermission == .granted
        } else {
            return AVAudioSession.sharedInstance().recordPermission == .granted
        }
    }
    
    func getSpeechRecognitionPermissionStatus() -> Bool {
        return SFSpeechRecognizer.authorizationStatus() == .authorized
    }
    
    // MARK: - Permission Requesting (for onboarding)
    
    func requestPermissions() async -> Result<Bool, AppError> {
        await Logger.shared.info("Requesting microphone and speech recognition permissions", category: .voiceCapture)
        
        // Request microphone permission
        let microphoneResult = await requestMicrophonePermission()
        guard case .success(true) = microphoneResult else {
            return microphoneResult
        }
        
        // Request speech recognition permission
        let speechResult = await requestSpeechRecognitionPermission()
        return speechResult
    }
    
    func startRecording() async -> Result<Void, AppError> {
        await Logger.shared.info("Starting voice recording", category: .voiceCapture)
        
        // Clear previous state
        currentError = nil
        transcription = ""
        
        // Check permissions first - don't request, just check
        let hasPermissions = await checkPermissions()
        guard hasPermissions else {
            let error = AppError.voiceCapture(.permissionDenied)
            currentError = error
            return .failure(error)
        }
        
        // For prototype phase, use mock recording
        if configuration.isDebugMode {
            return await startMockRecording()
        } else {
            return await startRealRecording()
        }
    }
    
    func stopRecording() async -> Result<String, AppError> {
        await Logger.shared.info("Stopping voice recording", category: .voiceCapture)
        
        if configuration.isDebugMode {
            return await stopMockRecording()
        } else {
            return await stopRealRecording()
        }
    }
    
    // MARK: - Mock Recording (for prototype)
    
    private func startMockRecording() async -> Result<Void, AppError> {
        await MainActor.run {
            isRecording = true
        }
        
        // Simulate recording with realistic duration
        let recordingTime = Double.random(in: 1.5...4.0)
        recordingTimer = Timer.scheduledTimer(withTimeInterval: recordingTime, repeats: false) { [weak self] _ in
            Task {
                await self?.stopRecording()
            }
        }
        
        await Logger.shared.debug("Started mock recording for \(recordingTime) seconds", category: .voiceCapture)
        return .success(())
    }
    
    private func stopMockRecording() async -> Result<String, AppError> {
        await MainActor.run {
            isRecording = false
        }
        
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        // Generate realistic mock transcription
        guard let mockTranscription = mockTranscriptions.randomElement() else {
            let error = AppError.voiceCapture(.transcriptionFailed)
            currentError = error
            return .failure(error)
        }
        
        await MainActor.run {
            transcription = mockTranscription
        }
        
        await Logger.shared.debug("Mock transcription generated: \(mockTranscription)", category: .voiceCapture)
        return .success(mockTranscription)
    }
    
    // MARK: - Real Recording (for production)
    
    private func startRealRecording() async -> Result<Void, AppError> {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            let error = AppError.voiceCapture(.unavailable)
            currentError = error
            return .failure(error)
        }
        
        do {
            try await setupAudioSession()
            try setupAudioEngine()
            
            await MainActor.run {
                isRecording = true
            }
            
            // Start timeout timer
            recordingTimer = Timer.scheduledTimer(withTimeInterval: configuration.maxRecordingDuration, repeats: false) { [weak self] _ in
                Task {
                    await self?.stopRecording()
                }
            }
            
            return .success(())
            
        } catch {
            let appError = AppError.voiceCapture(.recordingFailed(error.localizedDescription))
            currentError = appError
            return .failure(appError)
        }
    }
    
    private func stopRealRecording() async -> Result<String, AppError> {
        await MainActor.run {
            isRecording = false
        }
        
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        audioEngine?.stop()
        recognitionRequest?.endAudio()
        
        // Wait for final transcription result
        return await withCheckedContinuation { continuation in
            // If we already have a transcription result, return it
            if !transcription.isEmpty {
                continuation.resume(returning: .success(transcription))
                return
            }
            
            // Otherwise wait a moment for the final result
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if !self.transcription.isEmpty {
                    continuation.resume(returning: .success(self.transcription))
                } else {
                    let error = AppError.voiceCapture(.transcriptionFailed)
                    self.currentError = error
                    continuation.resume(returning: .failure(error))
                }
            }
        }
    }
    
    // MARK: - Audio Setup
    
    private func setupSpeechRecognition() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        speechRecognizer?.delegate = self
    }
    
    private func setupAudioSession() async throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    private func setupAudioEngine() throws {
        audioEngine = AVAudioEngine()
        
        guard let audioEngine = audioEngine else {
            throw AppError.voiceCapture(.unavailable)
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true
        
        guard let recognitionRequest = recognitionRequest else {
            throw AppError.voiceCapture(.unavailable)
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor in
                guard let self = self else { return }
                
                if let result = result {
                    self.transcription = result.bestTranscription.formattedString
                    
                    if result.isFinal {
                        await Logger.shared.info("Final transcription: \(self.transcription)", category: .voiceCapture)
                    }
                }
                
                if let error = error {
                    await Logger.shared.error("Speech recognition error", error: error, category: .voiceCapture)
                    self.currentError = AppError.voiceCapture(.transcriptionFailed)
                }
            }
        }
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    // MARK: - Permission Requests
    
    func requestMicrophonePermission() async -> Result<Bool, AppError> {
        return await withCheckedContinuation { continuation in
            if #available(iOS 17.0, *) {
                AVAudioApplication.requestRecordPermission { granted in
                    if granted {
                        continuation.resume(returning: .success(true))
                    } else {
                        continuation.resume(returning: .failure(.voiceCapture(.permissionDenied)))
                    }
                }
            } else {
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    if granted {
                        continuation.resume(returning: .success(true))
                    } else {
                        continuation.resume(returning: .failure(.voiceCapture(.permissionDenied)))
                    }
                }
            }
        }
    }
    
    func requestSpeechRecognitionPermission() async -> Result<Bool, AppError> {
        return await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                switch status {
                case .authorized:
                    continuation.resume(returning: .success(true))
                case .denied, .restricted, .notDetermined:
                    continuation.resume(returning: .failure(.voiceCapture(.permissionDenied)))
                @unknown default:
                    continuation.resume(returning: .failure(.voiceCapture(.unavailable)))
                }
            }
        }
    }
    
    // MARK: - Cleanup
    
    private func cleanup() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        audioEngine = nil
    }
}

// MARK: - SFSpeechRecognizerDelegate

extension VoiceCaptureService: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        Task { @MainActor in
            if !available {
                await Logger.shared.warning("Speech recognizer became unavailable", category: .voiceCapture)
                currentError = AppError.voiceCapture(.unavailable)
            }
        }
    }
}