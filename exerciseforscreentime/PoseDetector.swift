//
//  PoseDetector.swift
//  exerciseforscreentime
//
//  Created by Hashem Abdelati on 2/2/26.
//

import Foundation
import Vision
import CoreGraphics

@MainActor
final class PoseDetector: ObservableObject {
    @Published var elbowAngle: Double? = nil
    @Published var statusText: String = "Finding pose..."

    private let request = VNDetectHumanBodyPoseRequest()
    private let handler = VNSequenceRequestHandler()

    // Call this from the camera thread (not main)
    func process(sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        do {
            try handler.perform([request], on: pixelBuffer)
            guard let obs = request.results?.first as? VNHumanBodyPoseObservation else {
                Task { @MainActor in
                    self.elbowAngle = nil
                    self.statusText = "No person detected"
                }
                return
            }

            let angle = computeBestElbowAngle(from: obs)

            Task { @MainActor in
                self.elbowAngle = angle
                self.statusText = angle == nil ? "Pose low confidence" : "Pose OK"
            }
        } catch {
            Task { @MainActor in
                self.elbowAngle = nil
                self.statusText = "Vision error"
            }
        }
    }

    private func computeBestElbowAngle(from obs: VNHumanBodyPoseObservation) -> Double? {
        // Try left arm, then right arm; pick the one with better confidence
        let left = elbowAngle(obs: obs, shoulder: .leftShoulder, elbow: .leftElbow, wrist: .leftWrist)
        let right = elbowAngle(obs: obs, shoulder: .rightShoulder, elbow: .rightElbow, wrist: .rightWrist)

        // Prefer non-nil; if both exist, choose the one closer to typical pushup range (or just pick left)
        if let l = left, let r = right {
            // pick the arm with angle closer to 110 as a rough “mid” posture (slightly more stable)
            return abs(l - 110) < abs(r - 110) ? l : r
        }
        return left ?? right
    }

    private func elbowAngle(obs: VNHumanBodyPoseObservation,
                            shoulder: VNHumanBodyPoseObservation.JointName,
                            elbow: VNHumanBodyPoseObservation.JointName,
                            wrist: VNHumanBodyPoseObservation.JointName) -> Double? {
        guard
            let s = try? obs.recognizedPoint(shoulder),
            let e = try? obs.recognizedPoint(elbow),
            let w = try? obs.recognizedPoint(wrist),
            s.confidence > 0.3, e.confidence > 0.3, w.confidence > 0.3
        else { return nil }

        // Vision points are normalized [0,1]. Angle math works fine on normalized coords.
        let sp = CGPoint(x: s.x, y: s.y)
        let ep = CGPoint(x: e.x, y: e.y)
        let wp = CGPoint(x: w.x, y: w.y)

        return angle(a: sp, b: ep, c: wp)
    }
    
}

