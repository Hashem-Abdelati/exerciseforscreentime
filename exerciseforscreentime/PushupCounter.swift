import Foundation

@MainActor
final class PushupCounter: ObservableObject {
    enum State { case up, down }

    @Published var reps: Int = 0
    @Published var phase: String = "Up"

    private var state: State = .up

    // Tune these thresholds after testing
    private let downThreshold = 80.0
    private let upThreshold = 155.0

    func update(with elbowAngle: Double?) -> Bool {
        guard let angle = elbowAngle else { return false }

        switch state {
        case .up:
            phase = "Up"
            if angle < downThreshold {
                state = .down
                phase = "Down"
            }
            return false

        case .down:
            phase = "Down"
            if angle > upThreshold {
                reps += 1
                state = .up
                phase = "Up"
                return true // rep completed
            }
            return false
        }
    }
}
