//
//  TimerView.swift
//  LoopTimer
//
//  Main timer interface
//

import SwiftUI

struct TimerView: View {
    @StateObject private var viewModel = TimerViewModel()
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            timerContent()
        }
    }

    @ViewBuilder
    private func timerContent() -> some View {
        VStack(spacing: 20) {
            Spacer()

            // Timer Display
            TimerDisplayView(
                timeInterval: viewModel.state == .idle ? 0 :
                    (viewModel.displayMode == .elapsed ? viewModel.elapsedTime : viewModel.remainingTime),
                displayMode: viewModel.displayMode,
                isIdle: viewModel.state == .idle,
                isPaused: viewModel.state == .paused,
                onTap: {
                    if viewModel.state != .idle {
                        viewModel.displayMode = viewModel.displayMode == .elapsed ? .remaining : .elapsed
                    }
                }
            )

            Spacer()

            // Time Picker (visible only when idle) or Duration Text
            Group {
                if viewModel.state == .idle {
                    TimerPickerView(
                        minutes: Binding(
                            get: { viewModel.selectedMinutes },
                            set: { viewModel.selectedMinutes = $0 }
                        ),
                        seconds: Binding(
                            get: { viewModel.selectedSeconds },
                            set: { viewModel.selectedSeconds = $0 }
                        )
                    )
                    .padding(.horizontal)
                } else {
                    // Show timer duration when running or paused
                    VStack {
                        Spacer()
                        Text(formatDuration(minutes: viewModel.selectedMinutes, seconds: viewModel.selectedSeconds))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.bottom, 8)
                    }
                }
            }
            .frame(height: 200)

            // Control Buttons
            TimerControlsView(
                state: viewModel.state,
                onPlayPause: viewModel.togglePlayPause,
                onStop: viewModel.stopTimer
            )

            Spacer()
        }
        .navigationTitle("Loop Timer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gearshape")
                        .foregroundColor(.secondary)
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    private func formatDuration(minutes: Int, seconds: Int) -> String {
        var parts: [String] = []

        if minutes > 0 {
            parts.append("\(minutes) min")
        }
        if seconds > 0 {
            parts.append("\(seconds) sec")
        }

        return parts.isEmpty ? "0 sec" : parts.joined(separator: " ")
    }
}

#Preview {
    TimerView()
}
