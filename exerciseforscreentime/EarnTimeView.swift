import SwiftUI

struct EarnTimeView: View {
    @ObservedObject var bank: TimeBank

    @StateObject private var detector = PoseDetector()
    @StateObject private var counter = PushupCounter()

    var body: some View {
        ZStack(alignment: .top) {
            PoseCameraView(detector: detector)
                .ignoresSafeArea(edges: [.top, .leading, .trailing]) // keep tab bar visible

            VStack(spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pushups to earn time")
                            .font(.headline)

                        Text("Reps: \(counter.reps) • Phase: \(counter.phase)")
                            .font(.subheadline)

                        Text("Time: \(bank.minutesRemaining) min")
                            .font(.subheadline)

                        if let angle = detector.elbowAngle {
                            Text(String(format: "Elbow angle: %.0f°", angle))
                                .font(.caption)
                        } else {
                            Text(detector.statusText)
                                .font(.caption)
                        }
                    }
                    Spacer()
                }
                .padding(12)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .padding(.horizontal)

                Spacer()
            }
        }
        .onReceive(detector.$elbowAngle) { angle in
            let completed = counter.update(with: angle)
            if completed {
                bank.addMinutes(1) // 1 pushup = 1 minute
            }
        }
    }
}
