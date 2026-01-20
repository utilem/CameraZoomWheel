//
//  ViewModel.swift
//  Camera-SwiftUI
//
//  Created by Gianluca Orpello on 27/02/24.
//

import Foundation
import CoreImage
import CameraZoomWheel

@MainActor
@Observable
final class ViewModel {
    var currentFrame: CGImage?

    private let cameraManager = CameraManager()

    init() {
        Task {
            await cameraManager.start()
            await handleCameraPreviews()
        }
    }

    private func handleCameraPreviews() async {
        for await image in cameraManager.previewStream {
            guard !Task.isCancelled else { break }
            currentFrame = image
        }
    }
}

extension ViewModel {

    var zoomValue: CGFloat {
        cameraManager.currentZoomValue
    }

    func setZoomValue(_ newValue: CGFloat) {
        Task {
            await cameraManager.setZoomValue(newValue)
        }
    }

    var zoomSteps: [ZoomStep] {
        cameraManager.availableZoomFactors
    }
}
