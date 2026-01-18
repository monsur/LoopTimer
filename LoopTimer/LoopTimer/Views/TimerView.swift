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
                onTap: {
                    if viewModel.state != .idle {
                        viewModel.displayMode = viewModel.displayMode == .elapsed ? .remaining : .elapsed
                    }
                }
            )

            Spacer()

            // Time Picker (always visible)
            TimerPickerView(
                hours: Binding(
                    get: { viewModel.selectedHours },
                    set: { viewModel.selectedHours = $0 }
                ),
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

            Spacer()

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
}

#Preview {
    TimerView()
}
