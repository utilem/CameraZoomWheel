//
//  ViewModel.swift
//  Camera-SwiftUI
//
//  Created by Gianluca Orpello on 27/02/24.
//

import Foundation
import CoreImage
import CameraZoomWheel

@Observable
class ViewModel {
    var currentFrame: CGImage?
    
    private let cameraManager = CameraManager()
    
    init() {
        Task {
            await handleCameraPreviews()
        }
    }
    
    func handleCameraPreviews() async {
        for await image in cameraManager.previewStream {
            Task { @MainActor in
                currentFrame = image
            }
        }
    }
}

extension ViewModel {

    var zoomValue: CGFloat {
        get {
            return cameraManager.zoomValue
        }
        set {
            cameraManager.zoomValue = newValue
        }
    }
    
    var zoomSteps: [ZoomStep] {
        cameraManager.availableZoomFactors
    }
}
