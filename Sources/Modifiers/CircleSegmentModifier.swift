//
//  CircleSegmentModifier.swift
//  CameraZoom
//
//  Created by Uwe Tilemann on 07.07.25.
//

import SwiftUI

/// A view modifier that frames content within a circular segment shape with glass-like styling.
///
/// `CircleSegmentModifier` combines framing, shape clipping, and glass effect styling
/// to create a sophisticated curved background for zoom wheel interfaces.
///
/// ## Features
/// - Frames content to specified dimensions
/// - Clips content to circular segment shape
/// - Applies translucent background with glass effect
/// - Uses precise geometric calculations for the curved shape
///
/// ## Usage
/// ```swift
/// Text("Zoom Control")
///     .circleSegment(width: 300, height: 130, color: .blue.opacity(0.4))
/// ```
public struct CircleSegmentModifier: ViewModifier {
    /// Width of the circular segment
    let width: CGFloat
    /// Height of the circular segment
    let height: CGFloat
    /// Background color for the segment
    let color: Color
    /// The circular segment shape used for clipping and background
    let segment : CircularSegment
    
    /// Creates a circular segment modifier with the specified dimensions.
    /// 
    /// - Parameters:
    ///   - width: Width of the circular segment
    ///   - height: Height of the circular segment
    ///   - color: Background color (defaults to semi-transparent black)
    public init(width: CGFloat, height: CGFloat, color: Color = .black.opacity(0.4)) {
        self.width = width
        self.height = height
        self.segment = CircularSegment(width: width, height: height)
        self.color = color
    }
    
    /// Applies the circular segment styling to the provided content.
    /// 
    /// - Parameter content: The content to style
    /// - Returns: Content framed and styled within a circular segment
    public func body(content: Content) -> some View {
            content
                .frame(width: width, height: height)
                .contentShape(segment)
                .background {
                    segment
                        .fill(color)
                        .frame(width: width, height: height)
                        .clipped()
                    
                }
                .likeGlass(color, shape: segment)
    }
}

extension View {
    /// Applies circular segment framing and styling to the view.
    /// 
    /// - Parameters:
    ///   - width: Width of the circular segment
    ///   - height: Height of the circular segment  
    ///   - color: Background color (defaults to semi-transparent black)
    /// - Returns: The view framed within a styled circular segment
    public func circleSegment(width: CGFloat, height: CGFloat, color: Color = .black.opacity(0.4)) -> some View {
        modifier(CircleSegmentModifier(width: width, height: height, color: color))
    }
}

#Preview {
    VStack {
        Spacer()
        
        Text("Hello, World!")
            .font(.largeTitle)
            .foregroundStyle(.white)
            .circleSegment(width: UIScreen.main.bounds.width, height: 130, color: .blue.opacity(0.4))
    }
    .ignoresSafeArea()
}
