//
//  TimerService.swift
//  LoopTimer
//
//  Core timer logic using DispatchSourceTimer
//

import Foundation
import Combine

class TimerService: ObservableObject {
    @Published private(set) var state: TimerState = .idle
    @Published private(set) var elapsedTime: TimeInterval = 0
    @Published private(set) var completedLoops: Int = 0

    private(set) var timerDuration: TimeInterval = 0
    private var startDate: Date?
    private var pausedElapsedTime: TimeInterval = 0

    private var timer: DispatchSourceTimer?
    private let timerQueue = DispatchQueue(label: "com.looptimer.timerqueue")

    var onLoopComplete: (() -> Void)?

    init() {
        // Attempt to restore state on launch
        restoreState()
    }

    // MARK: - Public Methods

    func start(duration: TimeInterval) {
        guard state == .idle else { return }

        self.timerDuration = duration
        self.elapsedTime = 0
        self.completedLoops = 0
        self.pausedElapsedTime = 0
        self.startDate = Date()

        state = .running
        startTimer()
        saveState()
    }

    func pause() {
        guard state == .running else { return }

        stopTimer()
        pausedElapsedTime = elapsedTime
        startDate = nil
        state = .paused
        saveState()
    }

    func resume() {
        guard state == .paused else { return }

        startDate = Date()
        state = .running
        startTimer()
        saveState()
    }

    func stop() {
        stopTimer()
        startDate = nil
        pausedElapsedTime = 0
        elapsedTime = 0
        completedLoops = 0
        state = .idle
        clearSavedState()
    }

    // MARK: - State Restoration from Live Activity

    func restoreRunningState(duration: TimeInterval, elapsedTime: TimeInterval, additionalLoops: Int = 0) {
        guard state == .idle else { return }

        self.timerDuration = duration
        self.elapsedTime = elapsedTime
        self.pausedElapsedTime = elapsedTime
        self.completedLoops += additionalLoops
        self.startDate = Date()
        self.state = .running
        startTimer()
        saveState()
    }

    func restorePausedState(duration: TimeInterval, elapsedTime: TimeInterval) {
        guard state == .idle else { return }

        self.timerDuration = duration
        self.elapsedTime = elapsedTime
        self.pausedElapsedTime = elapsedTime
        self.startDate = nil
        self.state = .paused
        saveState()
    }

    var remainingTime: TimeInterval {
        return max(0, timerDuration - elapsedTime)
    }

    var progress: Double {
        guard timerDuration > 0 else { return 0 }
        return elapsedTime / timerDuration
    }

    // MARK: - Private Methods

    private func startTimer() {
        let timer = DispatchSource.makeTimerSource(queue: timerQueue)
        timer.schedule(deadline: .now(), repeating: .milliseconds(100))

        timer.setEventHandler { [weak self] in
            self?.timerTick()
        }

        timer.resume()
        self.timer = timer
    }

    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }

    private func timerTick() {
        guard let startDate = startDate, state == .running else { return }

        let elapsed = pausedElapsedTime + Date().timeIntervalSince(startDate)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Check for loop completion
            if elapsed >= self.timerDuration {
                // Play chime
                self.onLoopComplete?()

                // Increment loop counter
                self.completedLoops += 1

                // Reset elapsed time to remainder
                self.elapsedTime = elapsed.truncatingRemainder(dividingBy: self.timerDuration)
                self.pausedElapsedTime = self.elapsedTime
                self.startDate = Date()
            } else {
                self.elapsedTime = elapsed
            }
        }
    }

    // MARK: - State Persistence

    private func saveState() {
        let defaults = UserDefaults.standard
        defaults.set(state.rawValue, forKey: "timerState")
        defaults.set(timerDuration, forKey: "timerDuration")
        defaults.set(startDate, forKey: "timerStartDate")
        defaults.set(pausedElapsedTime, forKey: "timerPausedElapsed")
        defaults.set(completedLoops, forKey: "timerCompletedLoops")
    }

    private func restoreState() {
        let defaults = UserDefaults.standard

        guard let stateString = defaults.string(forKey: "timerState"),
              let savedState = TimerState(rawValue: stateString),
              savedState != .idle else {
            return
        }

        let duration = defaults.double(forKey: "timerDuration")
        guard duration > 0 else { return }

        self.timerDuration = duration
        self.pausedElapsedTime = defaults.double(forKey: "timerPausedElapsed")
        self.completedLoops = defaults.integer(forKey: "timerCompletedLoops")

        if savedState == .running, let savedStartDate = defaults.object(forKey: "timerStartDate") as? Date {
            // Calculate elapsed time since app was backgrounded/terminated
            let timeSinceStart = Date().timeIntervalSince(savedStartDate)
            let totalElapsed = pausedElapsedTime + timeSinceStart

            // Calculate completed loops during background
            let newLoops = Int(totalElapsed / duration)
            self.completedLoops += newLoops

            // Set current elapsed to remainder
            self.elapsedTime = totalElapsed.truncatingRemainder(dividingBy: duration)
            self.pausedElapsedTime = self.elapsedTime
            self.startDate = Date()
            self.state = .running

            startTimer()
        } else if savedState == .paused {
            self.elapsedTime = pausedElapsedTime
            self.state = .paused
        }
    }

    private func clearSavedState() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "timerState")
        defaults.removeObject(forKey: "timerDuration")
        defaults.removeObject(forKey: "timerStartDate")
        defaults.removeObject(forKey: "timerPausedElapsed")
        defaults.removeObject(forKey: "timerCompletedLoops")
    }
}
