//
//  Triangle.swift
//  CameraZoom
//
//  Created by Uwe Tilemann on 07.07.25.
//

import SwiftUI

/// A triangular shape used as a directional indicator in the zoom wheel.
///
/// `Triangle` creates a simple triangular path that can be rotated and styled
/// to serve as a visual pointer indicating the current zoom position.
///
/// ## Usage
/// ```swift
/// Triangle()
///     .fill(Color.yellow)
///     .frame(width: 8, height: 14)
///     .rotationEffect(.degrees(180))
/// ```
public struct Triangle: Shape {
    /// Creates a triangular path within the specified rectangle.
    /// 
    /// - Parameter rect: The rectangle in which to create the triangle path
    /// - Returns: A triangular path centered in the rectangle
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

