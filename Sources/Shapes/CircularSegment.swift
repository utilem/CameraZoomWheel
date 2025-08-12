//
//  CircularSegment.swift
//  CameraZoom
//
//  Created by Uwe Tilemann on 07.07.25.
//

import SwiftUI

/// A curved background shape that creates a circular segment for the zoom wheel.
///
/// `CircularSegment` generates a curved arc background using precise geometric calculations
/// based on the chord-height formula. This shape serves as the curved backdrop for the
/// zoom wheel interface.
///
/// ## Technical Details
/// Uses the chord-height formula to calculate the radius:
/// `r = (chord² / (8 * height)) + (height / 2)`
///
/// The segment angle is derived from: `α = arccos((r - h) / r)`
///
/// ## Usage
/// ```swift
/// CircularSegment(width: UIScreen.main.bounds.width, height: 130)
///     .fill(Color.black.opacity(0.4))
/// ```
public struct CircularSegment: Shape {
    /// Width of the circular segment (chord length)
    let width: CGFloat
    
    /// Height of the visible circular segment
    let height: CGFloat
    
    private var radius: CGFloat {
        let chord = width
        let segmentHeight = height
        return (chord * chord) / (8 * segmentHeight) + (segmentHeight / 2)
    }
    
    private var centerY: CGFloat {
        return radius - height
    }
    
    private var segmentAngle: CGFloat {
        let alpha = acos((radius - height) / radius)
        return alpha * 180 / CGFloat.pi
    }
    
    /// Creates a circular segment path within the specified rectangle.
    /// 
    /// - Parameter rect: The rectangle in which to create the circular segment
    /// - Returns: A curved path representing the circular segment
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: width / 2, y: height + centerY)
        let startAngle = 90 - segmentAngle
        let endAngle = 90 + segmentAngle
        
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(startAngle),
            endAngle: .degrees(endAngle),
            clockwise: true
        )
        return path
    }
}

