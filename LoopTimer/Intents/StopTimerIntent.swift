import AppIntents
import Foundation

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
