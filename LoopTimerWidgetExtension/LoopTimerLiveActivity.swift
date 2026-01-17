//
//  LoopTimerLiveActivity.swift
//  LoopTimerWidgetExtension
//
//  Live Activity widget for lock screen
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LoopTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            // Lock screen / banner UI
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded view
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "timer")
                        .foregroundColor(.blue)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text("Loop \(context.state.currentLoop)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        timerDisplay(context: context)
                        progressBar(context: context)
                    }
                    .padding(.horizontal)
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundColor(.blue)
            } compactTrailing: {
                Text(timerText(context: context))
                    .font(.caption2)
                    .monospacedDigit()
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

                Text("Loop \(context.state.currentLoop)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }

            timerDisplay(context: context)

            progressBar(context: context)
        }
        .padding()
        .activityBackgroundTint(Color.black.opacity(0.25))
        .activitySystemActionForegroundColor(.white)
    }

    @ViewBuilder
    private func timerDisplay(context: ActivityViewContext<TimerActivityAttributes>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Elapsed")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(context.state.elapsedTime.formattedTime())
                    .font(.title2.monospacedDigit())
                    .fontWeight(.semibold)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("Remaining")
                    .font(.caption)
                    .foregroundColor(.secondary)

                let remaining = context.attributes.timerDuration - context.state.elapsedTime
                Text(max(0, remaining).formattedTime())
                    .font(.title2.monospacedDigit())
                    .fontWeight(.semibold)
            }
        }
    }

    @ViewBuilder
    private func progressBar(context: ActivityViewContext<TimerActivityAttributes>) -> some View {
        let progress = context.state.elapsedTime / context.attributes.timerDuration

        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))

                Rectangle()
                    .fill(Color.blue)
                    .frame(width: geometry.size.width * CGFloat(min(progress, 1.0)))
            }
        }
        .frame(height: 8)
        .cornerRadius(4)
    }

    private func timerText(context: ActivityViewContext<TimerActivityAttributes>) -> String {
        let remaining = context.attributes.timerDuration - context.state.elapsedTime
        return max(0, remaining).formattedTimeShort()
    }
}

// Extension to use TimeInterval formatting from main app
extension TimeInterval {
    func formattedTime() -> String {
        let hours = Int(self) / 3600
        let minutes = Int(self) / 60 % 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    func formattedTimeShort() -> String {
        if self < 3600 {
            let minutes = Int(self) / 60
            let seconds = Int(self) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
        return formattedTime()
    }
}
