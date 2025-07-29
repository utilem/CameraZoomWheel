//
//  ZoomControl.swift
//  CameraZoom
//
//  Created by Uwe Tilemann on 07.07.25.
//

import SwiftUI

@MainActor
public struct ZoomControl: View {
    @Binding var zoomLevel: CGFloat
    let zoomSteps: [ZoomStep]

    let minZoomLevel: CGFloat
    let maxZoomLevel: CGFloat
    
    let buttonZoomValues: [ZoomStep] = ZoomStep.zoomButtons
    
    @State private var showSlider = false
    @State private var longPressTimer: Timer?
    @State private var hideTimer: Timer?
    @State private var isLongPressing = false
    @State private var isAnimatingSlider = false
    
    @State private var previousDragLocation: CGPoint?
    @State private var sliderIsDragging = false  // Für Slider Drag State

    public init(zoomLevel: Binding<CGFloat>, steps: [ZoomStep] = ZoomStep.defaultSteps) {
        self._zoomLevel = zoomLevel
        self.zoomSteps = steps
        self.minZoomLevel = steps.first!.zoom
        self.maxZoomLevel = steps.last!.zoom
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            if showSlider {
                // Zoom Slider
                ZoomWheel(
                    zoomLevel: $zoomLevel,
                    minZoomLevel: minZoomLevel,
                    maxZoomLevel: maxZoomLevel,
                    zoomSteps: zoomSteps,
                    height: 130
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.9)),
                    removal: .opacity.combined(with: .scale(scale: 0.9))
                ))
            } else {
                // Zoom Button Bar
                ZoomButtonBar(
                    selectedZoom: $zoomLevel,
                    zoomValues: buttonZoomValues
                )
                .padding(.bottom)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.9)),
                    removal: .opacity.combined(with: .scale(scale: 1.1))
                ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showSlider)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if showSlider {
                        // Forward drag events to the slider
                        sliderIsDragging = true
                        handleSliderDrag(value)
                    } else {
                        // Start long press if not already started
                        startLongPress()
                    }
                }
                .onEnded { _ in
                    if showSlider {
                        // End slider drag
                        sliderIsDragging = false
                        endSliderDrag()
                    } else {
                        // Reset state and end long press
                        endLongPress()
                    }
                }
        )
    }
    
    private func animateSlider(show: Bool) {
        // Animate slider appearance
        isAnimatingSlider = true
        showSlider = show
        
        // Reset animation flag after animation completes
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            Task { @MainActor in
                isAnimatingSlider = false
            }
        }
    }

    private func startLongPress() {
        guard !isLongPressing else { return }
        
        // Stop existing timer
        longPressTimer?.invalidate()
        
        // Start new timer
        longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            // Long Press triggered
            Task { @MainActor in
                isLongPressing = true
                
                // Reset previous location when switching to slider mode
                previousDragLocation = nil
                
                animateSlider(show: true)
            }
        }
    }
    
    private func endLongPress() {
        // Stop timer
        longPressTimer?.invalidate()
        longPressTimer = nil

        hideSlider()
    }

    private func hideSlider() {
        hideTimer?.invalidate()
        hideTimer = nil

        // Hide slider if it was shown
        if isLongPressing, !sliderIsDragging {
            hideTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                Task { @MainActor in
                    // Long Press triggered
                    isLongPressing = false
                    
                    animateSlider(show: false)
                    
                    hideTimer?.invalidate()
                    hideTimer = nil
                }
            }
        }
    }

    // Drag handling for the slider
    private func handleSliderDrag(_ value: DragGesture.Value) {
        // Block drag events during slider animation
        guard !isAnimatingSlider else { return }
        
        hideTimer?.invalidate()
        hideTimer = nil

        // Use relative delta calculation between consecutive drag events
        if let previousLocation = previousDragLocation {
            let deltaX = value.location.x - previousLocation.x
            updateZoomFromDrag(deltaX)
        }
        
        // Update previous location for next delta calculation
        previousDragLocation = value.location
    }
    
    private func endSliderDrag() {
        previousDragLocation = nil
        // Snapping logic could be added here
        snapToNearestZoomStep()
        hideSlider()
   }
    
    // Use ZoomWheel's logarithmic functions for consistent calculation
    private func updateZoomFromDrag(_ deltaX: CGFloat) {
        // Convert current zoom to angle using ZoomWheel's logic
        let currentAngle = logarithmicZoomToAngle(zoomLevel)
        
        // Apply sensitivity to deltaX and convert to angle delta
        let sensitivity: Double = 0.5 // Reduced sensitivity for smoother control
        let angleDelta = -Double(deltaX) * sensitivity // Correct direction
        
        // Calculate new angle and convert back to zoom
        let newAngle = currentAngle + angleDelta
        let boundedAngle = max(45.0, min(135.0, newAngle)) // Clamp to 45°-135° range
        let newZoomLevel = logarithmicAngleToZoom(boundedAngle)
        
        let snappedZoomLevel = applyDragSnapping(newZoomLevel)
        zoomLevel = max(minZoomLevel, min(maxZoomLevel, snappedZoomLevel))
    }
    
    // Logarithmic distribution functions from ZoomWheel
    private func logarithmicZoomToAngle(_ zoom: Double) -> Double {
        let logMin = log(minZoomLevel)
        let logMax = log(maxZoomLevel)
        let logZoom = log(zoom)
        
        let progress = (logZoom - logMin) / (logMax - logMin)
        return 45 + progress * 90 // From 45° to 135°
    }
    
    private func logarithmicAngleToZoom(_ angle: Double) -> Double {
        let progress = (angle - 45) / 90.0 // Normalize from 45°-135° to 0-1
        
        let logMin = log(minZoomLevel)
        let logMax = log(maxZoomLevel)
        let logZoom = logMin + progress * (logMax - logMin)
        
        return exp(logZoom)
    }
    
    private func applyDragSnapping(_ targetZoom: Double) -> Double {
        let snapThreshold: Double = 0.05 // Sensitivity for snapping during drag

        // Use only zoomSteps as snap points
        let snapPoints = zoomSteps.map { $0.zoom }

        // Find nearest snap point
        if let nearestSnap = snapPoints.min(by: { abs($0 - targetZoom) < abs($1 - targetZoom) }) {
            let distance = abs(nearestSnap - targetZoom)

            if distance < snapThreshold {
                // Smooth magnetic attraction to snap point
                let snapStrength: Double = 0.2 // Strength of the magnetic effect
                return targetZoom + (nearestSnap - targetZoom) * snapStrength
            }
        }

        return targetZoom
    }

    private func snapToNearestZoomStep() {
        let snapThreshold = 0.05 // Much smaller threshold to only snap when very close

        // Use only zoomSteps as snap points
        let snapPoints = zoomSteps.map { $0.zoom }

        if let nearestStep = snapPoints.min(by: { abs($0 - zoomLevel) < abs($1 - zoomLevel) }) {
            let distance = abs(nearestStep - zoomLevel)

            if distance < snapThreshold {
                zoomLevel = nearestStep
            }
        }
    }
}
