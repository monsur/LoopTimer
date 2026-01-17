//
//  AudioService.swift
//  LoopTimer
//
//  Audio session setup and chime playback
//

import AVFoundation
import Foundation

class AudioService {
    private var audioPlayer: AVAudioPlayer?
    private let chimeFileName = "chime_bell" // Hardcoded bell chime

    init() {
        setupAudioSession()
        prepareAudioPlayer()
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
        // Ensure audio session is active
        setupAudioSession()

        // Play the chime
        audioPlayer?.play()
    }

    // MARK: - Private Methods

    private func prepareAudioPlayer() {
        guard let soundURL = Bundle.main.url(forResource: chimeFileName, withExtension: "caf") else {
            print("Audio file not found: \(chimeFileName).caf")
            audioPlayer = nil
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Failed to prepare audio player: \(error)")
            audioPlayer = nil
        }
    }
}
