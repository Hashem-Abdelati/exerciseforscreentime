//
//  PoseCameraView.swift
//  exerciseforscreentime
//
//  Created by Hashem Abdelati on 2/2/26.
//

import SwiftUI
import AVFoundation
import Vision

struct PoseCameraView: UIViewControllerRepresentable {
    @ObservedObject var detector: PoseDetector

    func makeUIViewController(context: Context) -> CameraViewController {
        let vc = CameraViewController()
        vc.detector = detector
        return vc
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

/// Simple UIKit camera controller that forwards frames to PoseDetector
final class CameraViewController: UIViewController {
    var detector: PoseDetector?

    private let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let previewLayer = AVCaptureVideoPreviewLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        session.sessionPreset = .high
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)

        configureSession()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }

    private func configureSession() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                  for: .video,
                                                  position: .front) else {
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) { session.addInput(input) }
        } catch {
            return
        }

        let queue = DispatchQueue(label: "camera.frames.queue")
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        videoOutput.alwaysDiscardsLateVideoFrames = true

        // Use a common pixel format Vision likes
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        ]

        if session.canAddOutput(videoOutput) { session.addOutput(videoOutput) }

        // Orientation: portrait
        if let conn = videoOutput.connection(with: .video), conn.isVideoOrientationSupported {
            conn.videoOrientation = .portrait
        }

        session.startRunning()
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        detector?.process(sampleBuffer: sampleBuffer)
    }
}
