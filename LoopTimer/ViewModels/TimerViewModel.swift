//
//  TimerViewModel.swift
//  LoopTimer
//
//  Coordinates timer service and manages UI state
//

import Foundation
import Combine
import SwiftUI

class TimerViewModel: ObservableObject {
    @AppStorage("selectedMinutes") var selectedMinutes: Int = 5
    @AppStorage("selectedSeconds") var selectedSeconds: Int = 0
    @AppStorage("displayMode") var displayMode: DisplayMode = .elapsed
    @AppStorage("selectedChimeSound") private var selectedChimeSound: String = "Bell"

    private let timerService: TimerService
    private let audioService: AudioService
    private let liveActivityService: LiveActivityService
    private var cancellables = Set<AnyCancellable>()

    var state: TimerState {
        timerService.state
    }

    var elapsedTime: TimeInterval {
        timerService.elapsedTime
    }

    var remainingTime: TimeInterval {
        timerService.remainingTime
    }

    var timerDuration: TimeInterval {
        timerService.timerDuration
    }

    var completedLoops: Int {
        timerService.completedLoops
    }

    var progress: Double {
        timerService.progress
    }

    init(timerService: TimerService = TimerService(), audioService: AudioService = AudioService(), liveActivityService: LiveActivityService = LiveActivityService()) {
        self.timerService = timerService
        self.audioService = audioService
        self.liveActivityService = liveActivityService

        // Set up loop completion handler
        timerService.onLoopComplete = { [weak self] in
            self?.handleLoopComplete()
        }

        // Observe timer service state changes
        timerService.$state
            .sink { [weak self] state in
                self?.objectWillChange.send()
                self?.updateLiveActivity()
            }
            .store(in: &cancellables)

        timerService.$elapsedTime
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                self?.updateLiveActivity()
            }
            .store(in: &cancellables)

        timerService.$completedLoops
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                self?.updateLiveActivity()
            }
            .store(in: &cancellables)
    }

    private func handleLoopComplete() {
        audioService.playChime(soundName: selectedChimeSound)
    }

    // MARK: - Public Methods

    func startTimer() {
        let duration = TimeInterval(selectedMinutes * 60 + selectedSeconds)
        guard duration > 0 else { return }
        timerService.start(duration: duration)
        liveActivityService.startActivity(duration: duration, startDate: Date())
    }

    func pauseTimer() {
        timerService.pause()
        updateLiveActivity()
    }

    func resumeTimer() {
        timerService.resume()
        updateLiveActivity()
    }

    func stopTimer() {
        timerService.stop()
        liveActivityService.endActivity()
    }

    private func updateLiveActivity() {
        guard state != .idle else { return }

        liveActivityService.updateActivity(
            elapsedTime: elapsedTime,
            isRunning: state == .running,
            currentLoop: completedLoops + 1
        )
    }

    func togglePlayPause() {
        switch state {
        case .idle:
            startTimer()
        case .running:
            pauseTimer()
        case .paused:
            resumeTimer()
        }
    }
}
