//
//  LiveActivityService.swift
//  LoopTimer
//
//  Manages Live Activity lifecycle
//

import ActivityKit
import Foundation

class LiveActivityService {
    private var currentActivity: Activity<TimerActivityAttributes>?
    private var updateTimer: Timer?

    // MARK: - Public Methods

    func startActivity(duration: TimeInterval, startDate: Date) {
        #if targetEnvironment(simulator)
        print("Live Activities not supported in simulator")
        return
        #endif

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled")
            return
        }

        // End any existing activity
        endActivity()

        let attributes = TimerActivityAttributes(
            timerDuration: duration,
            startDate: startDate
        )

        let initialState = TimerActivityAttributes.ContentState(
            elapsedTime: 0,
            isRunning: true,
            currentLoop: 1
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil)
            )
            self.currentActivity = activity
            print("Live Activity started successfully")

            // Start periodic updates
            startPeriodicUpdates()
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    func updateActivity(elapsedTime: TimeInterval, isRunning: Bool, currentLoop: Int) {
        #if targetEnvironment(simulator)
        return
        #endif

        guard let activity = currentActivity else { return }

        let updatedState = TimerActivityAttributes.ContentState(
            elapsedTime: elapsedTime,
            isRunning: isRunning,
            currentLoop: currentLoop
        )

        Task {
            await activity.update(ActivityContent(state: updatedState, staleDate: nil))
        }
    }

    func endActivity() {
        #if targetEnvironment(simulator)
        return
        #endif

        updateTimer?.invalidate()
        updateTimer = nil

        guard let activity = currentActivity else { return }

        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            print("Live Activity ended")
        }

        currentActivity = nil
    }

    // MARK: - Private Methods

    private func startPeriodicUpdates() {
        // Update activity every 5 seconds to keep it in sync
        updateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            // The activity will be updated by the timer service
            // This timer is just to ensure periodic refresh
        }
    }

    deinit {
        endActivity()
    }
}
