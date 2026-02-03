import SwiftUI
import UIKit

struct EarnTimeView: View {
    @ObservedObject var bank: TimeBank

    @StateObject private var detector = PoseDetector()
    @StateObject private var counter = PushupCounter()

    @State private var repPulse = false

    var body: some View {
        ZStack(alignment: .top) {
            // Camera background
            PoseCameraView(detector: detector)
                .ignoresSafeArea(edges: [.top, .leading, .trailing])

            // Top gradient to keep text readable without blocking the camera
            LinearGradient(
                colors: [Color.black.opacity(0.55), Color.black.opacity(0.05)],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()

            VStack(spacing: 10) {
                topHUD

                // slim progress bar (visual feedback without taking space)
                progressBar
                    .padding(.horizontal, 16)

                Spacer()
            }
            .padding(.top, 10)

            // Small floating rep bubble near bottom (doesn't cover the middle)
            VStack {
                Spacer()
                repBubble
                    .padding(.bottom, 18)
            }
        }
        .onReceive(detector.$elbowAngle) { angle in
            let completed = counter.update(with: angle)
            if completed {
                bank.addMinutes(1)
                repCelebration()
            }
        }
    }

    // MARK: - UI

    private var topHUD: some View {
        HStack(spacing: 10) {
            pill(
                title: "Time",
                value: "\(bank.minutesRemaining) min",
                systemImage: "clock.fill"
            )

            pill(
                title: "Reps",
                value: "\(counter.reps)",
                systemImage: "number.circle.fill"
            )

            Spacer()

            pill(
                title: "Phase",
                value: counter.phase,
                systemImage: "figure.strengthtraining.traditional"
            )
        }
        .padding(.horizontal, 16)
    }

    private var repBubble: some View {
        HStack(spacing: 10) {
            Image(systemName: "flame.fill")
                .foregroundStyle(.white.opacity(0.9))

            Text("+1 min per rep")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))

            Spacer(minLength: 8)

            Text("Reps: \(counter.reps)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .frame(maxWidth: 360)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .scaleEffect(repPulse ? 1.03 : 1.0)
        .animation(.spring(response: 0.22, dampingFraction: 0.7), value: repPulse)
        .padding(.horizontal, 16)
    }

    private var progressBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Group {
                    if let angle = detector.elbowAngle {
                        Text("Elbow: \(Int(angle))°")
                    } else {
                        Text(detector.statusText)
                    }
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.85))

                Spacer()

                Text("Down → Up = 1 rep")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.75))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.15))

                    Capsule()
                        .fill(Color.white.opacity(0.85))
                        .frame(width: geo.size.width * barFill)
                }
            }
            .frame(height: 6)
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    private func pill(title: String, value: String, systemImage: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: systemImage)
                .foregroundStyle(.white.opacity(0.9))

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
                Text(value)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    // MARK: - Helpers

    private var barFill: CGFloat {
        // Visual only: maps elbow angle to a 0...1 range for “down/up” feel.
        // If elbowAngle is nil, show 0.
        guard let a = detector.elbowAngle else { return 0 }
        // Clamp angle into [60, 170] then normalize
        let clamped = min(170, max(60, a))
        return CGFloat((clamped - 60) / (170 - 60))
    }

    private func repCelebration() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        repPulse = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            repPulse = false
        }
    }
}
