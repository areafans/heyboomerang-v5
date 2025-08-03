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
        
        // Don't set up speech recognizer immediately - wait for authorization
        // This prevents iOS 17+ authorization timing issues
        Logger.shared.debug("VoiceCaptureService initialized, waiting for authorization before setting up speech recognizer", category: .voiceCapture)
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
        Logger.shared.info("Requesting microphone and speech recognition permissions", category: .voiceCapture)
        
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
        Logger.shared.info("Starting voice recording", category: .voiceCapture)
        
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
        
        // Use real recording now that backend is ready
        // Note: Change this back to check isDebugMode if you want mock recording in debug builds
        return await startRealRecording()
    }
    
    func stopRecording() async -> Result<String, AppError> {
        Logger.shared.info("Stopping voice recording", category: .voiceCapture)
        
        // Use real recording now that backend is ready
        return await stopRealRecording()
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
        
        Logger.shared.debug("Started mock recording for \(recordingTime) seconds", category: .voiceCapture)
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
        
        Logger.shared.debug("Mock transcription generated: \(mockTranscription)", category: .voiceCapture)
        return .success(mockTranscription)
    }
    
    // MARK: - Real Recording (for production)
    
    private func startRealRecording() async -> Result<Void, AppError> {
        // Clean up any previous session
        cleanup()
        
        // Wait a moment for cleanup to complete
        try? await Task.sleep(for: .milliseconds(100))
        
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            Logger.shared.error("Speech recognizer not available", category: .voiceCapture)
            let error = AppError.voiceCapture(.unavailable)
            currentError = error
            return .failure(error)
        }
        
        // Check authorization status
        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        guard speechStatus == .authorized else {
            Logger.shared.error("Speech recognition not authorized: \(speechStatus)", category: .voiceCapture)
            let error = AppError.voiceCapture(.permissionDenied)
            currentError = error
            return .failure(error)
        }
        
        do {
            Logger.shared.info("Setting up audio session and engine", category: .voiceCapture)
            try await setupAudioSession()
            try await setupAudioEngine()
            
            await MainActor.run {
                isRecording = true
                transcription = "" // Clear any previous transcription
                currentError = nil // Clear any previous errors
            }
            
            // Start timeout timer
            recordingTimer = Timer.scheduledTimer(withTimeInterval: configuration.maxRecordingDuration, repeats: false) { [weak self] _ in
                Task {
                    let _ = await self?.stopRecording()
                }
            }
            
            Logger.shared.info("Recording started successfully", category: .voiceCapture)
            return .success(())
            
        } catch {
            Logger.shared.error("Failed to start recording", error: error, category: .voiceCapture)
            let appError = AppError.voiceCapture(.recordingFailed(error.localizedDescription))
            await MainActor.run {
                currentError = appError
            }
            return .failure(appError)
        }
    }
    
    private func stopRealRecording() async -> Result<String, AppError> {
        // Prevent multiple calls to stop recording
        let (wasRecording, currentTranscription) = await MainActor.run {
            guard isRecording else { return (false, transcription) }
            isRecording = false
            return (true, transcription)
        }
        
        guard wasRecording else {
            Logger.shared.debug("Stop recording called but not currently recording", category: .voiceCapture)
            return .success(currentTranscription) // Return whatever transcription we have
        }
        
        // Cancel timer to prevent it from calling stop again
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        Logger.shared.debug("Stopping recording, current transcription: '\(currentTranscription)'", category: .voiceCapture)
        
        // If we already have a transcription, return it immediately
        if !currentTranscription.isEmpty {
            Logger.shared.info("Using existing transcription: '\(currentTranscription)'", category: .voiceCapture)
            
            // End audio and stop engine
            recognitionRequest?.endAudio()
            audioEngine?.stop()
            
            return .success(currentTranscription)
        }
        
        // IMPORTANT: Don't stop audio engine immediately - let speech recognition finish
        recognitionRequest?.endAudio()
        
        // Wait for final transcription result - give speech recognition time to process
        return await withCheckedContinuation { continuation in
            // Check multiple times with shorter intervals for better responsiveness
            var checkCount = 0
            let maxChecks = 12 // Check 12 times over 3 seconds (increased timeout)
            var hasResumed = false
            
            func checkForFinalTranscription() {
                Task { @MainActor in
                    guard !hasResumed else { return }
                    
                    let latestTranscription = self.transcription
                    checkCount += 1
                    
                    Logger.shared.debug("Check \(checkCount): transcription = '\(latestTranscription)'", category: .voiceCapture)
                    
                    // If we have transcription, return it
                    if !latestTranscription.isEmpty {
                        Logger.shared.info("Final transcription found: '\(latestTranscription)'", category: .voiceCapture)
                        
                        // Now stop the audio engine
                        self.audioEngine?.stop()
                        
                        hasResumed = true
                        continuation.resume(returning: .success(latestTranscription))
                        return
                    }
                    
                    // If we've checked enough times, give up
                    if checkCount >= maxChecks {
                        Logger.shared.warning("No transcription available after \(maxChecks) checks", category: .voiceCapture)
                        
                        // Stop the audio engine
                        self.audioEngine?.stop()
                        
                        let error = AppError.voiceCapture(.transcriptionFailed)
                        self.currentError = error
                        hasResumed = true
                        continuation.resume(returning: .failure(error))
                        return
                    }
                    
                    // Check again in 250ms
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        checkForFinalTranscription()
                    }
                }
            }
            
            // Start checking
            checkForFinalTranscription()
        }
    }
    
    // MARK: - Audio Setup
    
    private func setupSpeechRecognition() {
        // IMPORTANT: Only instantiate SFSpeechRecognizer after authorization is confirmed
        // This prevents iOS 17+ authorization timing issues
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            Logger.shared.warning("Speech recognition not authorized yet, deferring setup", category: .voiceCapture)
            return
        }
        
        // Use the device's preferred locale, fallback to US English
        let preferredLocale = Locale.preferredLanguages.first.flatMap { Locale(identifier: $0) } ?? Locale(identifier: "en-US")
        speechRecognizer = SFSpeechRecognizer(locale: preferredLocale)
        speechRecognizer?.delegate = self
        
        Logger.shared.info("Speech recognizer set up with locale: \(preferredLocale.identifier)", category: .voiceCapture)
    }
    
    private func setupAudioSession() async throws {
        let audioSession = AVAudioSession.sharedInstance()
        
        // Use default mode for better speech recognition
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Request permission if not already granted (iOS 17.0+)
        let _ = await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
    
    private func setupAudioEngine() async throws {
        audioEngine = AVAudioEngine()
        
        guard let audioEngine = audioEngine else {
            throw AppError.voiceCapture(.unavailable)
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Log audio format for debugging
        Logger.shared.debug("Audio format - Sample Rate: \(recordingFormat.sampleRate), Channels: \(recordingFormat.channelCount)", category: .voiceCapture)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true
        
        // CRITICAL: Use on-device recognition to avoid iOS 17+ server-side bugs
        recognitionRequest?.requiresOnDeviceRecognition = true
        
        // Configure for better speech detection
        if #available(iOS 16.0, *) {
            recognitionRequest?.addsPunctuation = true
        }
        
        // Add task hint for better recognition
        if #available(iOS 13.0, *) {
            recognitionRequest?.taskHint = .dictation
        }
        
        guard let recognitionRequest = recognitionRequest else {
            throw AppError.voiceCapture(.unavailable)
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor in
                guard let self = self else { return }
                
                if let result = result {
                    let newTranscription = result.bestTranscription.formattedString
                    
                    // Only update if we have actual text (iOS 17+ bug workaround)
                    if !newTranscription.isEmpty {
                        // Ensure UI updates happen on MainActor
                        if Thread.isMainThread {
                            self.transcription = newTranscription
                        } else {
                            DispatchQueue.main.async {
                                self.transcription = newTranscription
                            }
                        }
                        Logger.shared.debug("Updated transcription: '\(newTranscription)'", category: .voiceCapture)
                    }
                    
                    if result.isFinal {
                        Logger.shared.info("Final transcription: '\(self.transcription)'", category: .voiceCapture)
                    }
                }
                
                if let error = error {
                    let errorCode = (error as NSError).code
                    let errorDomain = (error as NSError).domain
                    
                    // Filter out known spurious iOS 17+ errors
                    if errorDomain == "kAFAssistantErrorDomain" && (errorCode == 1101 || errorCode == 1107) {
                        Logger.shared.debug("Ignoring spurious iOS 17+ speech recognition error: \(errorCode)", category: .voiceCapture)
                        return
                    }
                    
                    // Only log real errors
                    if !error.localizedDescription.contains("No speech detected") {
                        Logger.shared.error("Speech recognition error", error: error, category: .voiceCapture)
                    }
                    
                    // Only set error if transcription is empty AND it's not a spurious error
                    if self.transcription.isEmpty && !(errorDomain == "kAFAssistantErrorDomain" && errorCode == 1101) {
                        self.currentError = AppError.voiceCapture(.transcriptionFailed)
                    }
                }
            }
        }
        
        // Remove any existing tap first
        inputNode.removeTap(onBus: 0)
        
        // Install tap with better buffer size for speech recognition
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: recordingFormat) { buffer, when in
            recognitionRequest.append(buffer)
            
            // Debug: Check if we're getting audio samples
            let samples = buffer.floatChannelData?[0]
            let frameLength = Int(buffer.frameLength)
            if frameLength > 0, let samples = samples {
                var sum: Float = 0
                for i in 0..<frameLength {
                    sum += abs(samples[i])
                }
                let average = sum / Float(frameLength)
                
                // Only log if there's significant audio activity
                if average > 0.01 {
                    Logger.shared.debug("Audio detected - Average amplitude: \(average)", category: .voiceCapture)
                }
            }
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    // MARK: - Permission Requests
    
    func requestMicrophonePermission() async -> Result<Bool, AppError> {
        return await withCheckedContinuation { continuation in
            // Since we're iOS 17.0+, use the new AVAudioApplication API
            AVAudioApplication.requestRecordPermission { granted in
                if granted {
                    continuation.resume(returning: .success(true))
                } else {
                    continuation.resume(returning: .failure(.voiceCapture(.permissionDenied)))
                }
            }
        }
    }
    
    func requestSpeechRecognitionPermission() async -> Result<Bool, AppError> {
        return await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { [weak self] status in
                switch status {
                case .authorized:
                    // NOW set up speech recognizer after authorization is confirmed
                    self?.setupSpeechRecognition()
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
        Logger.shared.debug("Cleaning up voice capture session", category: .voiceCapture)
        
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        // Stop audio engine and remove tap
        if let audioEngine = audioEngine {
            audioEngine.stop()
            if audioEngine.inputNode.numberOfInputs > 0 {
                audioEngine.inputNode.removeTap(onBus: 0)
            }
        }
        
        // IMPORTANT: Proper task cancellation pattern for iOS 17+
        if let task = recognitionTask {
            task.cancel()
            recognitionTask = nil
        }
        
        if let request = recognitionRequest {
            request.endAudio()
            recognitionRequest = nil
        }
        
        audioEngine = nil
        
        // Deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            Logger.shared.debug("Audio session deactivated", category: .voiceCapture)
        } catch {
            Logger.shared.warning("Failed to deactivate audio session: \(error)", category: .voiceCapture)
        }
    }
}

// MARK: - SFSpeechRecognizerDelegate

extension VoiceCaptureService: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        Task { @MainActor in
            if !available {
                Logger.shared.warning("Speech recognizer became unavailable", category: .voiceCapture)
                self.currentError = AppError.voiceCapture(.unavailable)
            }
        }
    }
}