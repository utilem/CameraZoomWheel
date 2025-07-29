//
//  ZoomWheel.swift
//  CameraZoom
//
//  Created by Uwe Tilemann on 07.07.25.
//

import SwiftUI

public struct ZoomWheel: View {
    @Binding var zoomLevel: CGFloat
    let minZoomLevel: CGFloat
    let maxZoomLevel: CGFloat
    let zoomSteps: [ZoomStep]
    let height: CGFloat

    let width: CGFloat = UIScreen.main.bounds.width
        
    @State private var wheelRotation: CGFloat = 0
    @State private var targetRotation: CGFloat = 0
    
    @State private var cachedTickMarks: [CGFloat] = []
    @State private var cachedTickAngles: [CGFloat] = []

    @State private var minRotation: CGFloat = 0
    @State private var maxRotation: CGFloat = 0
    
    public init(
        zoomLevel: Binding<CGFloat>,
        minZoomLevel: CGFloat,
        maxZoomLevel: CGFloat,
        zoomSteps: [ZoomStep],
        height: CGFloat
    ) {
        self._zoomLevel = zoomLevel
        self.minZoomLevel = minZoomLevel
        self.maxZoomLevel = maxZoomLevel
        self.zoomSteps = zoomSteps
        self.height = height
    }
    
    private var radius: CGFloat {
        // Calculate radius from chord length (width) and segment height
        // Formula: r = (chord² / (8 * height)) + (height / 2)
        let chord = width
        let segmentHeight = height
        return (chord * chord) / (8 * segmentHeight) + (segmentHeight / 2)
    }
    
    private var centerY: CGFloat {
        // Calculate the correct center Y position for the circle
        // so that the visible segment has exactly the specified height
        return radius - height
    }
    
    @ViewBuilder
    private var tickMarks: some View {
        // Fine grid lines with 0.1 spacing near zoom steps
        ForEach(Array(zip(cachedTickMarks, cachedTickAngles).enumerated()), id: \.offset) { index, tickData in
            let (tickZoom, angle) = tickData
            let isMainTick = tickZoom == minZoomLevel || tickZoom.truncatingRemainder(dividingBy: 1) == 0
            
            Rectangle()
                .fill(Color.white.opacity(isMainTick ? 1 : 0.3))
                .frame(
                    width: 1,
                    height: 17
                )
                .offset(y: -radius + 13)
                .rotationEffect(.degrees(angle))
        }
    }
    
    @ViewBuilder
    private var markings: some View {
        // Main markings for zoom steps (logarithmically distributed)
        ForEach(Array(zoomSteps.enumerated()), id: \.offset) { index, step in
            let angle = logarithmicZoomToAngle(step.zoom)
            let isActive = abs(step.zoom - zoomLevel) < 0.1
            
            let distanceToCenter = abs(angle + wheelRotation - 0)
            let normalizedDistance = min(distanceToCenter / 15.0, 1.0) // 30° als Referenzbereich
            
            // Berechne Scaling und Opacity basierend auf Distanz
            let scale =  (0.3 + 0.7 * normalizedDistance)
            let opacity = normalizedDistance
            
            Group {
                if step.type == .focalLength || step.type == .value || isActive {
                    VStack(spacing: 0) {
                        Text(formatZoomValue(step.zoom))
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(isActive ? .yellow : .white)
                            .scaleEffect(scale)
                            .opacity(opacity)
                        if step.type == .focalLength, let unit = step.focalLength {
                            Text(unit)
                                .font(.caption2)
                                .scaleEffect(1)
                                .foregroundColor(isActive ? .yellow.opacity(0.9) : .white.opacity(0.7))
                                .opacity(isActive ? 1 : opacity)
                        }
                    }
                    .offset(y: -radius + 40)
                } else if step.type == .dot {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 3, height: 3)
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .offset(y: -radius + 37)
                }
            }
            .rotationEffect(.degrees(angle))
        }
    }
    
    public var body: some View {
        ZStack {
            // Rotating zoom wheel
            ZStack {
                tickMarks
                markings
            }
            .rotationEffect(.degrees(wheelRotation))
            .position(x: width / 2, y: height + centerY)
            .clipped() // Clip to visible area
        }
        .circleSegment(width: width, height: height)
        .overlay {
            // Fixed yellow indicator at the top center
            Group {
                Triangle()
                    .fill(Color.yellow)
                    .frame(width: 8, height: 14)
                    .rotationEffect(.degrees(180))
                    .position(x: width / 2, y: 8)
                
                // Central zoom display
                Text("\(formatZoomValue(zoomLevel, suffix: "×"))")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                    .position(x: width / 2, y: 35)
            }

        }
        .task {
            cachedTickMarks = generateTickMarks()
            cachedTickAngles = cachedTickMarks.map { logarithmicZoomToAngle($0) }

            minRotation = -logarithmicZoomToAngle(maxZoomLevel)
            maxRotation = -logarithmicZoomToAngle(minZoomLevel)
        }
        .onAppear {
            // Correct initial rotation:
            // The yellow indicator is at 90°, we want the current zoomLevel to appear there
            // So we need to rotate the wheel so that the marking for zoomLevel is at 90°
            let currentZoomAngle = logarithmicZoomToAngle(zoomLevel)
            wheelRotation = -currentZoomAngle
            targetRotation = -currentZoomAngle

        }
        .onChange(of: zoomLevel) { oldValue, newValue in
            let currentZoomAngle = logarithmicZoomToAngle(newValue)
            targetRotation = -currentZoomAngle
            
            // Smooth interpolation
            func lerp(from: Double, to: Double, factor: Double) -> Double {
                return from + (to - from) * factor
            }
            wheelRotation = lerp(from: wheelRotation, to: targetRotation, factor: 0.6)
        }
    }
    
    private func generateTickMarks() -> [CGFloat] {
        var ticks: [CGFloat] = []
        
        // Generate ticks from minZoomLevel to maxZoomLevel
        var currentZoom = minZoomLevel
        
        while currentZoom <= maxZoomLevel {
            ticks.append(currentZoom)
            
            // Determine step size based on zoom level
            let stepSize: CGFloat
            if currentZoom < 1.0 {
                stepSize = 0.1  // 0.1 steps for zoom < 1x
            } else if currentZoom < 10.0 {
                stepSize = 0.1  // 0.1 steps for zoom 1x-10x
            } else {
                stepSize = 1.0  // 1.0 steps for zoom > 10x
            }
            
            currentZoom += stepSize
            
            // Round to avoid floating point precision issues
            currentZoom = (currentZoom * 10).rounded() / 10
        }
        
        return ticks.filter { $0 >= minZoomLevel && $0 <= maxZoomLevel }
    }
    
    private func formatZoomValue(_ zoom: CGFloat, suffix: String? = nil) -> String {
        Formatters.numberFormatter(zoom, digits: zoom.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 1, suffix: suffix)
    }
    
    // Logarithmic distribution of zoom values across 90° (45° to 135°)
    private func logarithmicZoomToAngle(_ zoom: CGFloat) -> CGFloat {
        // Logarithmic scaling
        let logMin = log(minZoomLevel)
        let logMax = log(maxZoomLevel)
        let logZoom = log(zoom)
        
        let progress = (logZoom - logMin) / (logMax - logMin)
        return 45 + progress * 90 // From 45° to 135°
    }
    
    private func logarithmicAngleToZoom(_ angle: CGFloat) -> CGFloat {
        let progress = (angle - 45) / 90.0 // Normalize from 45°-135° to 0-1
        
        // Logarithmic inverse transformation
        let logMin = log(minZoomLevel)
        let logMax = log(maxZoomLevel)
        let logZoom = logMin + progress * (logMax - logMin)
        
        return exp(logZoom)
    }
}
