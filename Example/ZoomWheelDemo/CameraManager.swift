//
//  CameraManager.swift
//  Camera-SwiftUI
//
//  Created by Gianluca Orpello on 27/02/24.
//

@preconcurrency import AVFoundation
import CoreImage

import CameraZoomWheel

// MARK: - Sample Buffer Delegate

/// Separate delegate class for handling sample buffer callbacks.
/// Must be a class (not actor) to conform to NSObjectProtocol and the delegate protocol.
/// Marked nonisolated to prevent implicit MainActor isolation from project settings.
@preconcurrency
final class CameraSampleBufferDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, @unchecked Sendable {
    private let addToPreviewStream: @Sendable (CGImage) -> Void

    nonisolated init(addToPreviewStream: @escaping @Sendable (CGImage) -> Void) {
        self.addToPreviewStream = addToPreviewStream
        super.init()
    }

    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let currentFrame = sampleBuffer.cgImage else {
            return
        }
        addToPreviewStream(currentFrame)
    }
}

// MARK: - Camera Manager Actor

actor CameraManager {

    private let captureSession = AVCaptureSession()
    private var deviceInput: AVCaptureDeviceInput?
    private var videoOutput: AVCaptureVideoDataOutput?
    nonisolated let systemPreferredCamera = AVCaptureDevice.default(for: .video)

    private let sessionQueue = DispatchQueue(label: "video.preview.session")

    private var sampleBufferDelegate: CameraSampleBufferDelegate?
    private var streamContinuation: AsyncStream<CGImage>.Continuation?

    nonisolated let previewStream: AsyncStream<CGImage>

    // MARK: - Zoom Properties

    nonisolated var availableZoomFactors: [ZoomStep] {
        systemPreferredCamera?.zoomSteps ?? ZoomStep.defaultSteps
    }

    nonisolated var currentZoomValue: CGFloat {
        systemPreferredCamera?.videoZoomFactor ?? 1
    }

    func setZoomValue(_ newValue: CGFloat) {
        guard let systemPreferredCamera else { return }
        guard newValue >= systemPreferredCamera.minAvailableVideoZoomFactor else { return }
        guard newValue <= systemPreferredCamera.maxAvailableVideoZoomFactor else { return }

        do {
            try systemPreferredCamera.lockForConfiguration()
            systemPreferredCamera.ramp(toVideoZoomFactor: newValue, withRate: 4)
            systemPreferredCamera.unlockForConfiguration()
        } catch {
            print("error zooming camera: \(error)")
        }
    }

    // MARK: - Initialization

    init() {
        var continuation: AsyncStream<CGImage>.Continuation?
        previewStream = AsyncStream { cont in
            continuation = cont
        }
        streamContinuation = continuation

        let addToStream: @Sendable (CGImage) -> Void = { [continuation] image in
            continuation?.yield(image)
        }
        sampleBufferDelegate = CameraSampleBufferDelegate(addToPreviewStream: addToStream)
    }

    // MARK: - Session Management

    func start() async {
        await configureSession()
        await startSession()
    }

    private var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            var isAuthorized = status == .authorized

            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }

            return isAuthorized
        }
    }

    private func configureSession() async {
        guard await isAuthorized,
              let systemPreferredCamera,
              let deviceInput = try? AVCaptureDeviceInput(device: systemPreferredCamera)
        else { return }

        captureSession.beginConfiguration()

        defer {
            captureSession.commitConfiguration()
        }

        let videoOutput = AVCaptureVideoDataOutput()

        if let delegate = sampleBufferDelegate {
            videoOutput.setSampleBufferDelegate(delegate, queue: sessionQueue)
        }

        guard captureSession.canAddInput(deviceInput) else {
            return
        }

        guard captureSession.canAddOutput(videoOutput) else {
            return
        }

        captureSession.addInput(deviceInput)
        captureSession.addOutput(videoOutput)

        videoOutput.connection(with: .video)?.videoRotationAngle = 90

        self.deviceInput = deviceInput
        self.videoOutput = videoOutput
    }

    private func startSession() async {
        guard await isAuthorized else { return }

        await withCheckedContinuation { continuation in
            sessionQueue.async { [captureSession] in
                captureSession.startRunning()
                continuation.resume()
            }
        }
    }

    func stopSession() async {
        await withCheckedContinuation { continuation in
            sessionQueue.async { [captureSession] in
                captureSession.stopRunning()
                continuation.resume()
            }
        }
    }
}

// MARK: - Extensions

extension CMSampleBuffer {
    nonisolated var cgImage: CGImage? {
        let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(self)
        guard let imagePixelBuffer = pixelBuffer else { return nil }
        return CIImage(cvPixelBuffer: imagePixelBuffer).cgImage
    }
}

extension CIImage {
    nonisolated var cgImage: CGImage? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return cgImage
    }
}
