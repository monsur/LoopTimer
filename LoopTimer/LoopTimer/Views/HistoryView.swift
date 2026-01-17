//
//  HistoryView.swift
//  LoopTimer
//
//  Timer history list view
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TimerInstance.startedAt, order: .reverse) private var instances: [TimerInstance]

    var body: some View {
        NavigationStack {
            Group {
                if instances.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(instances) { instance in
                            HistoryRowView(instance: instance)
                        }
                        .onDelete(perform: deleteInstances)
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Timer History")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Your completed timer sessions will appear here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func deleteInstances(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(instances[index])
        }

        do {
            try modelContext.save()
        } catch {
            print("Failed to delete: \(error)")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TimerInstance.self, configurations: config)

    // Add sample data
    let sample1 = TimerInstance(
        duration: 300,
        startedAt: Date().addingTimeInterval(-3600),
        stoppedAt: Date().addingTimeInterval(-3000),
        completedLoops: 2,
        chimeName: "Bell"
    )
    let sample2 = TimerInstance(
        duration: 600,
        startedAt: Date().addingTimeInterval(-7200),
        stoppedAt: Date().addingTimeInterval(-6000),
        completedLoops: 5,
        chimeName: "Soft Chime"
    )

    container.mainContext.insert(sample1)
    container.mainContext.insert(sample2)

    return HistoryView()
        .modelContainer(container)
}
