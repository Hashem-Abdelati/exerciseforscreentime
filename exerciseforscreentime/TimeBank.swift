import Foundation

@MainActor
final class TimeBank: ObservableObject {
    @Published var minutesRemaining: Int {
        didSet { UserDefaults.standard.set(minutesRemaining, forKey: "minutesRemaining") }
    }

    init() {
        self.minutesRemaining = UserDefaults.standard.integer(forKey: "minutesRemaining")
    }

    func addMinutes(_ minutes: Int) {
        minutesRemaining += minutes
    }

    /// Returns true if successful
    func consumeMinutes(_ minutes: Int) -> Bool {
        guard minutesRemaining >= minutes else { return false }
        minutesRemaining -= minutes
        return true
    }
}
