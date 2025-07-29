//
//  ZoomStep.swift
//  CameraZoom
//
//  Created by Uwe Tilemann on 23.07.25.
//

import AVFoundation

public struct ZoomStep: Sendable {
    public let zoom: CGFloat
    public let focalLength: String?
    public let type: ZoomStep.DisplayType
    
    public enum DisplayType: Int, Sendable {
        case dot = 0            // Displays this step as a simple dot
        case value = 1          // Displays this step as a value like 0.5 or 1
        case focalLength = 2    // Like .value with additional focal length description if given
    }
    
    public init(zoom: CGFloat, focalLength: String? = nil, type: ZoomStep.DisplayType = .value) {
        self.zoom = zoom
        self.focalLength = focalLength
        self.type = type
    }
}

extension ZoomStep: Identifiable {
    public var id: Int { zoom.hashValue }
}

extension ZoomStep {
    public static let defaultSteps: [ZoomStep] = [
        .init(zoom: 0.5, focalLength: "13 MM", type: .focalLength),
        .init(zoom: 1.0, focalLength: "24 MM", type: .focalLength),
        .init(zoom: 1.2, focalLength: "28 MM", type: .dot),
        .init(zoom: 1.5, focalLength: "35 MM", type: .dot),
        .init(zoom: 2.0, focalLength: "48 MM", type: .value),
        .init(zoom: 3.0, focalLength: "77 MM", type: .focalLength),
        .init(zoom: 10.0, type: .value)
    ]
}

extension ZoomStep {
    public static let zoomButtons: [ZoomStep] = [
        .init(zoom: 0.5),
        .init(zoom: 1.0),
        .init(zoom: 2.0),
        .init(zoom: 3.0)
    ]
}

extension AVCaptureDevice {
    public var zoomSteps: [ZoomStep] {
        // Device-specific zoom steps based on actual camera capabilities
        var steps: [ZoomStep] = []
        
        // Add ultra-wide if available (< 1.0)
        if minAvailableVideoZoomFactor < 1.0 {
            steps.append(ZoomStep(zoom: minAvailableVideoZoomFactor, focalLength: "13mm", type: .focalLength))
        }
        
        // Add main camera
        steps.append(ZoomStep(zoom: 1.0, focalLength: "24mm", type: .focalLength))
        
        // Add telephoto levels if available
        if maxAvailableVideoZoomFactor >= 2.0 {
            steps.append(ZoomStep(zoom: 2.0, focalLength: "48mm", type: .value))
        }
        if maxAvailableVideoZoomFactor >= 3.0 {
            steps.append(ZoomStep(zoom: 3.0, focalLength: "77mm", type: .focalLength))
        }
        if maxAvailableVideoZoomFactor >= 5.0 {
            steps.append(ZoomStep(zoom: 5.0, focalLength: "120mm", type: .value))
        }
        
        // Add maximum zoom
        if maxAvailableVideoZoomFactor > 10.0 {
            steps.append(ZoomStep(zoom: 10.0, focalLength: "240mm", type: .value))
        }
        
        return steps
    }
}
