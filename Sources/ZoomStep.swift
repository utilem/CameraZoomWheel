//
//  ZoomStep.swift
//  CameraZoom
//
//  Created by Uwe Tilemann on 23.07.25.
//

import AVFoundation

/// Represents a discrete zoom level with display configuration for camera zoom controls.
///
/// `ZoomStep` defines a specific zoom factor along with how it should be displayed in the UI.
/// It supports different visual representations from simple dots to focal length labels.
///
/// ## Usage
/// ```swift
/// let ultraWide = ZoomStep(zoom: 0.5, focalLength: "13mm", type: .focalLength)
/// let main = ZoomStep(zoom: 1.0, focalLength: "24mm", type: .focalLength)
/// let tele = ZoomStep(zoom: 2.0, type: .value)
/// ```
public struct ZoomStep: Sendable {
    /// The zoom factor value (e.g., 0.5 for ultra-wide, 1.0 for main camera, 2.0 for 2x zoom)
    public let zoom: CGFloat
    
    /// Optional focal length description (e.g., "24mm", "48mm") shown in UI when type is `.focalLength`
    public let focalLength: String?
    
    /// How this zoom step should be visually represented in the interface
    public let type: ZoomStep.DisplayType
    
    /// Defines how a zoom step is visually represented in the user interface.
    public enum DisplayType: Int, Sendable {
        /// Displays this step as a simple dot indicator
        case dot = 0
        /// Displays this step as a zoom value (e.g., "0.5×", "2×")
        case value = 1
        /// Displays this step as a zoom value with focal length description (e.g., "1× 24mm")
        case focalLength = 2
    }
    
    /// Creates a new zoom step configuration.
    /// - Parameters:
    ///   - zoom: The zoom factor value
    ///   - focalLength: Optional focal length description for display
    ///   - type: How this step should be visually represented (defaults to `.value`)
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
    /// Default zoom steps providing a comprehensive range from ultra-wide to telephoto.
    ///
    /// Includes common camera focal lengths and zoom factors:
    /// - 0.5× (13mm) - Ultra-wide
    /// - 1.0× (24mm) - Main camera
    /// - 1.2× (28mm) - Slight telephoto (dot indicator)
    /// - 1.5× (35mm) - Portrait range (dot indicator)
    /// - 2.0× (48mm) - 2x telephoto
    /// - 3.0× (77mm) - 3x telephoto
    /// - 10.0× - Maximum zoom
    public static let defaultSteps: [ZoomStep] = [
        .init(zoom: 0.5, focalLength: "13 mm", type: .focalLength),
        .init(zoom: 1.0, focalLength: "24 mm", type: .focalLength),
        .init(zoom: 1.2, focalLength: "28 mm", type: .dot),
        .init(zoom: 1.5, focalLength: "35 mm", type: .dot),
        .init(zoom: 2.0, focalLength: "48 mm", type: .value),
        .init(zoom: 3.0, focalLength: "77 mm", type: .focalLength),
        .init(zoom: 10.0, type: .value)
    ]
}

extension ZoomStep {
    /// Creates device-specific zoom steps based on actual camera capabilities.
    ///
    /// This method generates an optimized set of zoom steps that match the physical capabilities
    /// of the camera device, ensuring users only see zoom levels that are actually achievable.
    ///
    /// - Parameters:
    ///   - minZoomFactor: Minimum available zoom factor from the camera device
    ///   - maxZoomFactor: Maximum available zoom factor from the camera device
    /// - Returns: Array of zoom steps tailored to the device's camera capabilities
    ///
    /// ## Behavior
    /// - **Ultra-wide**: Adds 0.5× (13mm) if `minZoomFactor == 0.5`
    /// - **Main camera**: Always includes 1× (24mm) plus intermediate steps
    /// - **Telephoto**: Progressively adds 2×, 3×, 5× based on `maxZoomFactor`
    /// - **Maximum**: Caps at 10× (240mm) for optimal user experience
    public static func zoomSteps(from minZoomFactor: CGFloat, to maxZoomFactor: CGFloat) -> [ZoomStep] {
        // Device-specific zoom steps based on actual camera capabilities
        var steps: [ZoomStep] = []
        
        // Add ultra-wide if available (< 1.0)
        if minZoomFactor == 0.5 {
            steps.append(ZoomStep(zoom: 0.5, focalLength: "13 mm", type: .focalLength))
        }
        
        if maxZoomFactor >= 1.0 {
            // Add main camera
            steps.append(ZoomStep(zoom: 1.0, focalLength: "24 mm", type: .focalLength))
            steps.append(ZoomStep(zoom: 1.2, focalLength: "28 mm", type: .dot))
            steps.append(ZoomStep(zoom: 1.5, focalLength: "35 mm", type: .dot))
        }
        
        // Add telephoto levels if available
        if maxZoomFactor >= 2.0 {
            steps.append(ZoomStep(zoom: 2.0, focalLength: "48 mm", type: minZoomFactor < 1.0 ? .value : .focalLength))
        }
        if maxZoomFactor >= 3.0 {
            steps.append(ZoomStep(zoom: 3.0, focalLength: "77 mm", type: .focalLength))
        }
        if maxZoomFactor >= 5.0 {
            steps.append(ZoomStep(zoom: 5.0, focalLength: "120 mm", type: .value))
        }
        
        // Add maximum zoom
        if maxZoomFactor > 10.0 {
            steps.append(ZoomStep(zoom: 10.0, focalLength: "240mm", type: .value))
        }
        
        return steps
    }
}

extension AVCaptureDevice {
    /// Generates device-specific zoom steps based on this camera's actual capabilities.
    ///
    /// This computed property automatically creates an optimized set of zoom steps that match
    /// what this specific camera device can achieve, providing a native iOS camera app experience.
    ///
    /// ## Usage
    /// ```swift
    /// guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
    /// let steps = camera.zoomSteps
    /// ZoomControl(zoomLevel: $zoomLevel, steps: steps)
    /// ```
    ///
    /// - Returns: Array of zoom steps tailored to this device's zoom range
    public var zoomSteps: [ZoomStep] {
        return ZoomStep.zoomSteps(from: minAvailableVideoZoomFactor, to: maxAvailableVideoZoomFactor)
    }
}
