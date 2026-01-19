//
//  LoopTimerLiveActivity.swift
//  LoopTimerWidgetExtension
//
//  Live Activity widget for lock screen with client-side countdown
//

import ActivityKit
import WidgetKit
import SwiftUI
import AppIntents
import Foundation

// MARK: - App Intents

@available(iOS 17.0, *)
struct StopTimerIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Stop Timer"
    static var description = IntentDescription("Stops the timer and dismisses the Live Activity")

    func perform() async throws -> some IntentResult {
        // Post notification to stop timer
        await MainActor.run {
            NotificationCenter.default.post(name: .stopTimerIntent, object: nil)
        }
        return .result()
    }
}

@available(iOS 17.0, *)
struct ToggleTimerIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Toggle Timer"
    static var description = IntentDescription("Pauses or resumes the timer")

    func perform() async throws -> some IntentResult {
        // Post notification to toggle timer state
        await MainActor.run {
            NotificationCenter.default.post(name: .toggleTimerIntent, object: nil)
        }
        return .result()
    }
}

// MARK: - Notification Names Extension

extension Notification.Name {
    static let stopTimerIntent = Notification.Name("stopTimerIntent")
    static let toggleTimerIntent = Notification.Name("toggleTimerIntent")
}

// MARK: - Widget Bundle

@main
struct LoopTimerWidgets: WidgetBundle {
    var body: some Widget {
        LoopTimerLiveActivity()
    }
}

struct LoopTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            // Lock screen / banner UI
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded view
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.state.isRunning ? "timer" : "pause.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    countdownDisplay(context: context)
                        .font(.title2.monospacedDigit())
                        .fontWeight(.semibold)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 16) {
                        // Toggle play/pause button
                        if #available(iOS 17.0, *) {
                            Button(intent: ToggleTimerIntent()) {
                                Image(systemName: context.state.isRunning ? "pause.fill" : "play.fill")
                                    .font(.title3)
                                    .frame(width: 44, height: 44)
                                    .background(Color.blue.opacity(0.2))
                                    .foregroundColor(.blue)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }

                        // Stop button
                        if #available(iOS 17.0, *) {
                            Button(intent: StopTimerIntent()) {
                                Image(systemName: "xmark")
                                    .font(.title3)
                                    .frame(width: 44, height: 44)
                                    .background(Color.red.opacity(0.2))
                                    .foregroundColor(.red)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 8)
                }
            } compactLeading: {
                Image(systemName: context.state.isRunning ? "timer" : "pause.fill")
                    .foregroundColor(.blue)
            } compactTrailing: {
                countdownDisplay(context: context)
                    .font(.caption2.monospacedDigit())
            } minimal: {
                Image(systemName: "timer")
                    .foregroundColor(.blue)
            }
        }
    }

    @ViewBuilder
    private func lockScreenView(context: ActivityViewContext<TimerActivityAttributes>) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(.blue)

                Text("Loop Timer")
                    .font(.headline)

                Spacer()

                if !context.state.isRunning {
                    Text("Paused")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    countdownDisplay(context: context)
                        .font(.title.monospacedDigit())
                        .fontWeight(.semibold)
                }

                Spacer()

                // Control buttons
                HStack(spacing: 12) {
                    if #available(iOS 17.0, *) {
                        Button(intent: ToggleTimerIntent()) {
                            Image(systemName: context.state.isRunning ? "pause.fill" : "play.fill")
                                .font(.title2)
                                .frame(width: 50, height: 50)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)

                        Button(intent: StopTimerIntent()) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .frame(width: 50, height: 50)
                                .background(Color.red.opacity(0.2))
                                .foregroundColor(.red)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding()
        .activityBackgroundTint(Color(.systemGray6).opacity(0.8))
        .activitySystemActionForegroundColor(Color.primary)
    }

    @ViewBuilder
    private func countdownDisplay(context: ActivityViewContext<TimerActivityAttributes>) -> some View {
        if context.state.isRunning {
            // Use client-side countdown when running
            Text(timerInterval: Date()...context.state.loopEndDate, countsDown: true)
        } else if let remaining = context.state.pausedRemainingTime {
            // Show static time when paused
            Text(formatTime(remaining))
        } else {
            Text("--:--")
        }
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(max(0, interval))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
