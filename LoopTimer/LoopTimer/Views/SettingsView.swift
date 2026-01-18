//
//  SettingsView.swift
//  LoopTimer
//
//  Settings screen (placeholder for future settings)
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("selectedChimeSound") private var selectedSound: String = "Bell"

    private var selectedSoundName: String {
        ChimeSound.allSounds.first { $0.id == selectedSound }?.name ?? "Bell"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink(destination: SoundPickerView()) {
                        HStack {
                            Text("Sounds")
                            Spacer()
                            Text(selectedSoundName)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
