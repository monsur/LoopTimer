//
//  LiveActivityService.swift
//  LoopTimer
//
//  Manages Live Activity lifecycle with date-based countdown
//

import ActivityKit
import Foundation

class LiveActivityService {
    private var currentActivity: Activity<TimerActivityAttributes>?
    private(set) var timerDuration: TimeInterval = 0

    var hasActiveActivity: Bool {
        currentActivity != nil
    }

    var currentActivityId: String? {
        currentActivity?.id
    }

    // MARK: - Public Methods

    func startActivity(duration: TimeInterval, loopEndDate: Date) {
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

        self.timerDuration = duration

        let attributes = TimerActivityAttributes(timerDuration: duration)

        let initialState = TimerActivityAttributes.ContentState(
            loopEndDate: loopEndDate,
            isRunning: true,
            pausedRemainingTime: nil
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil)
            )
            self.currentActivity = activity
            print("Live Activity started successfully")
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    func updateForLoopComplete(newLoopEndDate: Date) {
        #if targetEnvironment(simulator)
        return
        #endif

        guard let activity = currentActivity else { return }

        let updatedState = TimerActivityAttributes.ContentState(
            loopEndDate: newLoopEndDate,
            isRunning: true,
            pausedRemainingTime: nil
        )

        Task {
            await activity.update(ActivityContent(state: updatedState, staleDate: nil))
        }
    }

    func updateForPause(remainingTime: TimeInterval) {
        #if targetEnvironment(simulator)
        return
        #endif

        guard let activity = currentActivity else { return }

        let updatedState = TimerActivityAttributes.ContentState(
            loopEndDate: Date(),  // Not used when paused
            isRunning: false,
            pausedRemainingTime: remainingTime
        )

        Task {
            await activity.update(ActivityContent(state: updatedState, staleDate: nil))
        }
    }

    func updateForResume(newLoopEndDate: Date) {
        #if targetEnvironment(simulator)
        return
        #endif

        guard let activity = currentActivity else { return }

        let updatedState = TimerActivityAttributes.ContentState(
            loopEndDate: newLoopEndDate,
            isRunning: true,
            pausedRemainingTime: nil
        )

        Task {
            await activity.update(ActivityContent(state: updatedState, staleDate: nil))
        }
    }

    func endActivity() {
        #if targetEnvironment(simulator)
        return
        #endif

        guard let activity = currentActivity else { return }

        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            print("Live Activity ended")
        }

        currentActivity = nil
    }

    func endAllActivities() {
        #if targetEnvironment(simulator)
        return
        #endif

        Task {
            for activity in Activity<TimerActivityAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
        currentActivity = nil
    }

    // MARK: - State Restoration

    func attachToExistingActivity() -> (duration: TimeInterval, loopEndDate: Date, isRunning: Bool, remainingTime: TimeInterval?)? {
        #if targetEnvironment(simulator)
        return nil
        #endif

        guard let activity = Activity<TimerActivityAttributes>.activities.first else {
            return nil
        }

        self.currentActivity = activity
        self.timerDuration = activity.attributes.timerDuration

        let state = activity.content.state
        return (
            duration: activity.attributes.timerDuration,
            loopEndDate: state.loopEndDate,
            isRunning: state.isRunning,
            remainingTime: state.pausedRemainingTime
        )
    }

    deinit {
        endActivity()
    }
}
