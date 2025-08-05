//
//  LikeGlassModifier.swift
//  CameraZoomWheel
//
//  Created by Uwe Tilemann on 05.08.25.
//

import SwiftUI

/// A view modifier that applies a glass-like visual effect to content.
///
/// `LikeGlassModifier` provides a translucent background effect that mimics
/// frosted glass appearance. Currently uses a fallback implementation due to
/// iOS 26 beta compatibility issues with `.glassEffect()`.
///
/// ## Usage
/// ```swift
/// Text("Hello")
///     .likeGlass(.white, shape: RoundedRectangle(cornerRadius: 8))
/// ```
public struct LikeGlassModifier<S: Shape>: ViewModifier {
    /// The color used for the translucent background effect
    let color: Color
    /// The shape to apply the glass effect to
    let shape: S
    
    /// Applies the glass-like effect to the provided content.
    /// 
    /// - Parameter content: The content to apply the effect to
    /// - Returns: The content with glass-like background styling
    public func body(content: Content) -> some View {
//        if #available(iOS 26, *) {
//            content
//                .background(
//                    shape
//                        .fill(color.opacity(0.1))
//                )
//                .glassEffect(.regular, in: shape)
//        } else {
            content
                .background(
                    shape
                        .fill(color.opacity(0.1))
                )
//        }
    }
}

extension View {
    /// Applies a glass-like visual effect to the view.
    /// 
    /// - Parameters:
    ///   - color: The color for the translucent background (defaults to white)
    ///   - shape: The shape to apply the effect to (defaults to Capsule)
    /// - Returns: The view with glass-like styling applied
    public func likeGlass<S: Shape>(_ color: Color = .white, shape: S = Capsule()) -> some View {
        modifier(LikeGlassModifier(color: color, shape: shape))
    }
}

