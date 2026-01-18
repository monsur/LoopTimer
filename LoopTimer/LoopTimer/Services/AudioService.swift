//
//  AudioService.swift
//  LoopTimer
//
//  Audio session setup and chime playback
//

import AVFoundation
import AudioToolbox
import Foundation

class AudioService {
    private var audioPlayer: AVAudioPlayer?
    private let chimeFileName = "chime_bell" // Hardcoded bell chime
    private var useSystemSoundFallback: Bool = false

    init() {
        setupAudioSession()
        useSystemSoundFallback = !prepareAudioPlayer()

        if useSystemSoundFallback {
            print("Using system sound fallback (audio file not found)")
        }
    }

    // MARK: - Audio Session Setup

    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()

            // Set category to .playback to ensure:
            // - Audio plays even when device is on silent
            // - Audio continues in background
            // - Similar behavior to Clock app alarms
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)

            print("Audio session configured successfully")
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    // MARK: - Public Methods

    func playChime() {
        if useSystemSoundFallback {
            // Use system sound as fallback (1013 is a nice bell sound)
            AudioServicesPlaySystemSound(1013)
        } else {
            // Ensure audio session is active
            setupAudioSession()

            // Play the chime
            audioPlayer?.play()
        }
    }

    // MARK: - Private Methods

    private func prepareAudioPlayer() -> Bool {
        guard let soundURL = Bundle.main.url(forResource: chimeFileName, withExtension: "caf") else {
            print("Audio file not found: \(chimeFileName).caf")
            audioPlayer = nil
            return false
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
            return true
        } catch {
            print("Failed to prepare audio player: \(error)")
            audioPlayer = nil
            return false
        }
    }
}
