//
//  TimerViewModel.swift
//  LoopTimer
//
//  Coordinates timer service and manages UI state
//

import Foundation
import Combine
import SwiftUI
import SwiftData

class TimerViewModel: ObservableObject {
    @Published var selectedHours: Int = 0
    @Published var selectedMinutes: Int = 5
    @Published var selectedSeconds: Int = 0
    @Published var displayMode: DisplayMode = .elapsed

    private let timerService: TimerService
    private let audioService: AudioService
    private let liveActivityService: LiveActivityService
    private var modelContext: ModelContext?
    private var cancellables = Set<AnyCancellable>()

    private var timerStartDate: Date?

    @AppStorage("selectedChime") private var selectedChimeRaw: String = ChimeOption.bell.rawValue

    private var selectedChime: ChimeOption {
        ChimeOption(rawValue: selectedChimeRaw) ?? .bell
    }

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

    init(timerService: TimerService = TimerService(), audioService: AudioService = AudioService(), liveActivityService: LiveActivityService = LiveActivityService(), modelContext: ModelContext? = nil) {
        self.timerService = timerService
        self.audioService = audioService
        self.liveActivityService = liveActivityService
        self.modelContext = modelContext

        // Configure audio service with saved chime preference
        audioService.setChime(selectedChime)

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
        // Update audio service with current chime selection
        audioService.setChime(selectedChime)
        // Play the chime
        audioService.playChime()
    }

    // MARK: - Public Methods

    func startTimer() {
        let duration = TimeInterval(selectedHours * 3600 + selectedMinutes * 60 + selectedSeconds)
        guard duration > 0 else { return }
        timerStartDate = Date()
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
        saveTimerInstance()
        timerService.stop()
        liveActivityService.endActivity()
        timerStartDate = nil
    }

    private func updateLiveActivity() {
        guard state != .idle else { return }

        liveActivityService.updateActivity(
            elapsedTime: elapsedTime,
            isRunning: state == .running,
            currentLoop: completedLoops + 1
        )
    }

    private func saveTimerInstance() {
        guard let modelContext = modelContext,
              let startDate = timerStartDate,
              timerDuration > 0 else {
            return
        }

        let instance = TimerInstance(
            duration: timerDuration,
            startedAt: startDate,
            stoppedAt: Date(),
            completedLoops: completedLoops,
            chimeName: selectedChime.rawValue
        )

        modelContext.insert(instance)

        do {
            try modelContext.save()
        } catch {
            print("Failed to save timer instance: \(error)")
        }
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

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
}
