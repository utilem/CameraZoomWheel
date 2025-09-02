//
//  ZoomWheelConfiguration.swift
//  CameraZoomWheel
//
//  Created by Uwe Tilemann on 02.09.25.
//

import SwiftUI

/// Configuration options for customizing the appearance and behavior of zoom components.
///
/// `ZoomWheelConfiguration` provides a centralized way to configure visual and behavioral
/// aspects of both the zoom wheel and zoom control components, enabling consistent
/// customization across the entire zoom interface.
///
/// ## Usage
/// ```swift
/// let config = ZoomWheelConfiguration(
///     buttonOffset: -10,
///     height: 150,
///     displayFocalLength: false
/// )
/// 
/// ZoomControl(
///     zoomLevel: $zoomLevel,
///     configuration: config
/// )
/// ```
public struct ZoomWheelConfiguration {
    /// Vertical offset for the zoom button bar positioning.
    ///
    /// Positive values move buttons down, negative values move them up.
    /// Used to fine-tune the button bar position relative to the container.
    let buttonOffset: CGFloat
    
    /// Height of the zoom wheel component in points.
    ///
    /// Defines the visible height of the circular zoom slider. This affects
    /// the curvature and available arc length for zoom interaction.
    let height: CGFloat
    
    /// Whether to display focal length labels on zoom steps.
    ///
    /// When `true`, zoom steps with focal length information show both
    /// zoom factor and equivalent focal length (e.g., "2× 48mm").
    /// When `false`, only zoom factors are displayed.
    let displayFocalLength: Bool
    
    /// Creates a zoom wheel configuration with the specified parameters.
    ///
    /// - Parameters:
    ///   - buttonOffset: Vertical offset for button positioning (default: 0)
    ///   - height: Height of the zoom wheel component (default: 130)
    ///   - displayFocalLength: Whether to show focal length labels (default: true)
    public init(
        buttonOffset: CGFloat = 0,
        height: CGFloat = 130,
        displayFocalLength: Bool = true
    ) {
        self.buttonOffset = buttonOffset
        self.height = height
        self.displayFocalLength = displayFocalLength
    }
}

