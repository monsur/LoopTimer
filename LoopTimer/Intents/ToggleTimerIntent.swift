import AppIntents
import Foundation

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
