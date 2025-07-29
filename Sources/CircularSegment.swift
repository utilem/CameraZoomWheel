//
//  CircularSegment.swift
//  CameraZoom
//
//  Created by Uwe Tilemann on 07.07.25.
//

import SwiftUI

public struct CircularSegment: Shape {
    let width: CGFloat
    let height: CGFloat
    
    private var radius: CGFloat {
        let chord = width
        let segmentHeight = height
        return (chord * chord) / (8 * segmentHeight) + (segmentHeight / 2)
    }
    
    private var centerY: CGFloat {
        return radius - height
    }
    
    private var segmentAngle: Double {
        let alpha = acos((radius - height) / radius)
        return alpha * 180 / .pi
    }
    
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

