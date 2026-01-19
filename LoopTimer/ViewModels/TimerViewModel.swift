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

    @Published var showNotificationWarning: Bool = false

    private let timerService: TimerService
    private let audioService: AudioService
    private let liveActivityService: LiveActivityService
    private let notificationService: NotificationService
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

    init(
        timerService: TimerService = TimerService(),
        audioService: AudioService = AudioService(),
        liveActivityService: LiveActivityService = LiveActivityService(),
        notificationService: NotificationService = NotificationService.shared
    ) {
        self.timerService = timerService
        self.audioService = audioService
        self.liveActivityService = liveActivityService
        self.notificationService = notificationService

        // Set up loop completion handler
        timerService.onLoopComplete = { [weak self] in
            self?.handleLoopComplete()
        }

        // Observe timer service state changes
        timerService.$state
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        timerService.$elapsedTime
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        timerService.$completedLoops
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // Set up NotificationCenter observers for App Intents
        setupIntentObservers()

        // Set up state restoration observer
        setupStateRestorationObserver()
    }

    private func handleLoopComplete() {
        audioService.playChime(soundName: selectedChimeSound)

        // Update Live Activity with new loop end date
        let newLoopEndDate = Date().addingTimeInterval(timerDuration)
        liveActivityService.updateForLoopComplete(newLoopEndDate: newLoopEndDate)

        // Reschedule notifications for next loops
        Task {
            await notificationService.rescheduleFromDate(
                Date(),
                remainingTimeInCurrentLoop: timerDuration,
                duration: timerDuration,
                currentLoop: completedLoops + 1,
                soundName: selectedChimeSound
            )
        }
    }

    // MARK: - Intent Observers

    private func setupIntentObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleToggleTimerIntent),
            name: .toggleTimerIntent,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStopTimerIntent),
            name: .stopTimerIntent,
            object: nil
        )
    }

    @objc private func handleToggleTimerIntent() {
        DispatchQueue.main.async { [weak self] in
            self?.togglePlayPause()
        }
    }

    @objc private func handleStopTimerIntent() {
        DispatchQueue.main.async { [weak self] in
            self?.stopTimer()
        }
    }

    // MARK: - State Restoration

    private func setupStateRestorationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateRestoration(_:)),
            name: .restoreTimerState,
            object: nil
        )
    }

    @objc private func handleStateRestoration(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let contentState = userInfo["contentState"] as? TimerActivityAttributes.ContentState,
              let attributes = userInfo["attributes"] as? TimerActivityAttributes else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.restoreFromLiveActivity(attributes: attributes, state: contentState)
        }
    }

    private func restoreFromLiveActivity(attributes: TimerActivityAttributes, state: TimerActivityAttributes.ContentState) {
        // If timer service already has state, don't override
        guard timerService.state == .idle else { return }

        // Attach to existing activity
        _ = liveActivityService.attachToExistingActivity()

        // Calculate what the timer state should be based on Live Activity state
        if state.isRunning {
            let now = Date()
            let remainingTime = state.loopEndDate.timeIntervalSince(now)

            if remainingTime > 0 {
                // Timer is still in current loop
                let elapsed = attributes.timerDuration - remainingTime
                timerService.restoreRunningState(
                    duration: attributes.timerDuration,
                    elapsedTime: elapsed
                )
            } else {
                // Loop(s) completed while app was terminated
                let timeSinceLoopEnd = -remainingTime
                let additionalLoops = Int(timeSinceLoopEnd / attributes.timerDuration)
                let currentElapsed = timeSinceLoopEnd.truncatingRemainder(dividingBy: attributes.timerDuration)

                timerService.restoreRunningState(
                    duration: attributes.timerDuration,
                    elapsedTime: currentElapsed,
                    additionalLoops: additionalLoops + 1
                )

                // Update Live Activity with correct end date
                let newLoopEndDate = Date().addingTimeInterval(attributes.timerDuration - currentElapsed)
                liveActivityService.updateForLoopComplete(newLoopEndDate: newLoopEndDate)
            }

            // Reschedule notifications
            Task {
                await notificationService.rescheduleFromDate(
                    Date(),
                    remainingTimeInCurrentLoop: timerService.remainingTime,
                    duration: attributes.timerDuration,
                    currentLoop: timerService.completedLoops + 1,
                    soundName: selectedChimeSound
                )
            }
        } else if let pausedRemaining = state.pausedRemainingTime {
            // Timer was paused
            let elapsed = attributes.timerDuration - pausedRemaining
            timerService.restorePausedState(
                duration: attributes.timerDuration,
                elapsedTime: elapsed
            )
        }
    }

    // MARK: - Public Methods

    func startTimer() {
        let duration = TimeInterval(selectedMinutes * 60 + selectedSeconds)
        guard duration > 0 else { return }

        let startDate = Date()
        let loopEndDate = startDate.addingTimeInterval(duration)

        timerService.start(duration: duration)
        liveActivityService.startActivity(duration: duration, loopEndDate: loopEndDate)

        // Schedule notifications
        Task {
            // Check notification permission and show warning if needed
            await notificationService.checkAuthorizationStatus()

            if notificationService.isAuthorized {
                await notificationService.scheduleLoopNotifications(
                    startDate: startDate,
                    duration: duration,
                    soundName: selectedChimeSound
                )
            } else if notificationService.authorizationStatus == .denied {
                await MainActor.run {
                    showNotificationWarning = true
                }
            } else {
                // Request permission
                let granted = await notificationService.requestPermissions()
                if granted {
                    await notificationService.scheduleLoopNotifications(
                        startDate: startDate,
                        duration: duration,
                        soundName: selectedChimeSound
                    )
                } else {
                    await MainActor.run {
                        showNotificationWarning = true
                    }
                }
            }
        }
    }

    func pauseTimer() {
        let remaining = remainingTime
        timerService.pause()
        liveActivityService.updateForPause(remainingTime: remaining)

        // Cancel scheduled notifications
        Task {
            await notificationService.cancelAllNotifications()
        }
    }

    func resumeTimer() {
        let remaining = remainingTime
        let loopEndDate = Date().addingTimeInterval(remaining)

        timerService.resume()
        liveActivityService.updateForResume(newLoopEndDate: loopEndDate)

        // Reschedule notifications
        Task {
            if notificationService.isAuthorized {
                await notificationService.rescheduleFromDate(
                    Date(),
                    remainingTimeInCurrentLoop: remaining,
                    duration: timerDuration,
                    currentLoop: completedLoops + 1,
                    soundName: selectedChimeSound
                )
            }
        }
    }

    func stopTimer() {
        timerService.stop()
        liveActivityService.endActivity()

        // Cancel all notifications
        Task {
            await notificationService.cancelAllNotifications()
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

    func dismissNotificationWarning() {
        showNotificationWarning = false
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
