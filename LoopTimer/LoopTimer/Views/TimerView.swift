//
//  TimerView.swift
//  LoopTimer
//
//  Main timer interface
//

import SwiftUI
import SwiftData

struct TimerView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = TimerViewModel()

    var body: some View {
        NavigationStack {
            timerContent()
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }

    @ViewBuilder
    private func timerContent() -> some View {
        VStack(spacing: 20) {
            Spacer()

            // Display Mode Toggle (only when timer is active)
            if viewModel.state != .idle {
                Picker("Display Mode", selection: Binding(
                    get: { viewModel.displayMode },
                    set: { viewModel.displayMode = $0 }
                )) {
                    ForEach(DisplayMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 40)
            }

            // Timer Display
            TimerDisplayView(
                timeInterval: viewModel.state == .idle ? 0 :
                    (viewModel.displayMode == .elapsed ? viewModel.elapsedTime : viewModel.remainingTime),
                displayMode: viewModel.displayMode,
                isIdle: viewModel.state == .idle
            )

            // Progress Bar (only visible when timer is active)
            if viewModel.state != .idle {
                ProgressView(value: viewModel.progress)
                    .progressViewStyle(.linear)
                    .frame(height: 8)
                    .padding(.horizontal, 40)

                Text("Loop \(viewModel.completedLoops + 1)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Time Picker (only visible when idle)
            if viewModel.state == .idle {
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
            }

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
    }
}

#Preview {
    TimerView()
}
