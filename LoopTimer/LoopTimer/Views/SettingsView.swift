//
//  SettingsView.swift
//  LoopTimer
//
//  Settings screen for chime selection
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedChime") private var selectedChimeRaw: String = ChimeOption.bell.rawValue
    @State private var audioService = AudioService()

    private var selectedChime: ChimeOption {
        ChimeOption(rawValue: selectedChimeRaw) ?? .bell
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(ChimeOption.allCases) { chime in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(chime.rawValue)
                                    .font(.body)

                                Text(chime.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            // Preview button (except for None)
                            if chime != .none {
                                Button(action: {
                                    audioService.previewChime(chime)
                                }) {
                                    Image(systemName: "play.circle")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(.plain)
                            }

                            // Selection checkmark
                            if chime == selectedChime {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                                    .font(.body.weight(.semibold))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedChimeRaw = chime.rawValue
                        }
                    }
                } header: {
                    Text("Loop Completion Sound")
                } footer: {
                    Text("Choose the sound that plays when each timer loop completes. Sounds will play through headphones if connected, or through the speaker.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SettingsView()
}
