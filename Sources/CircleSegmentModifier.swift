//
//  CircleSegmentModifier.swift
//  CameraZoom
//
//  Created by Uwe Tilemann on 07.07.25.
//

import SwiftUI

public struct LikeGlassModifier<S: Shape>: ViewModifier {
    let color: Color
    let shape: S
    
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
    public func likeGlass<S: Shape>(_ color: Color = .white, shape: S = Capsule()) -> some View {
        modifier(LikeGlassModifier(color: color, shape: shape))
    }
}

public struct CircleSegmentModifier: ViewModifier {
    let width: CGFloat
    let height: CGFloat
    let color: Color
    let segment : CircularSegment
    
    public init(width: CGFloat, height: CGFloat, color: Color = .black.opacity(0.4)) {
        self.width = width
        self.height = height
        self.segment = CircularSegment(width: width, height: height)
        self.color = color
    }
    
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
