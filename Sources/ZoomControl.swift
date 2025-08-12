//
//  ZoomControl.swift
//  CameraZoom
//
//  Created by Uwe Tilemann on 07.07.25.
//

import SwiftUI

/// Main orchestrating component for camera zoom controls with dual interaction modes.
///
/// `ZoomControl` provides both discrete button-based zoom selection and continuous circular 
/// slider control, switching between modes via long press gesture. Features magnetic snapping 
/// to zoom steps and haptic feedback during interaction.
///
/// ## Features
/// - **Dual Interface**: Button bar for quick selection, circular wheel for precise control
/// - **Long Press Activation**: Hold to switch from buttons to continuous slider
/// - **Magnetic Snapping**: Smooth attraction to defined zoom steps during dragging
/// - **Haptic Feedback**: Tactile response when snapping to zoom levels
/// - **Auto-Hide**: Slider automatically disappears after inactivity
///
/// ## Usage
/// ```swift
/// struct CameraView: View {
///     @State private var zoomLevel: CGFloat = 1.0
///     
///     var body: some View {
///         ZStack {
///             CameraPreview()
///             VStack {
///                 Spacer()
///                 ZoomControl(zoomLevel: $zoomLevel)
///             }
///         }
///     }
/// }
/// ```
@MainActor
public struct ZoomControl: View {
    /// Current zoom level binding that updates as user interacts with controls
    @Binding var zoomLevel: CGFloat
    
    /// Array of discrete zoom steps that define snapping points and button values
    let zoomSteps: [ZoomStep]

    /// Minimum zoom level derived from first zoom step
    let minZoomLevel: CGFloat
    
    /// Maximum zoom level derived from last zoom step
    let maxZoomLevel: CGFloat
    
    // Remove hardcoded buttonZoomValues - will use zoomSteps directly
    
    @State private var showSlider = false
    @State private var longPressTimer: Timer?
    @State private var hideTimer: Timer?
    @State private var isLongPressing = false
    @State private var isAnimatingSlider = false
    
    @State private var previousDragLocation: CGPoint?
    @State private var sliderIsDragging = false  // Für Slider Drag State
    @State private var lastSnappedZoom: CGFloat = 0  // Track last snapped value for haptic feedback

    /// Creates a zoom control with the specified zoom level binding and steps.
    /// 
    /// - Parameters:
    ///   - zoomLevel: Binding to current zoom level that will be updated by user interaction
    ///   - steps: Array of zoom steps defining available zoom levels (defaults to `ZoomStep.defaultSteps`)
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
                    zoomValues: zoomSteps
                )
                .padding(.bottom)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.9)),
                    removal: .opacity.combined(with: .scale(scale: 1.1))
                ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showSlider)
        .sensoryFeedback(.increase, trigger: lastSnappedZoom)
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
        let currentAngle = zoomLevel.toZoomAngle(min: minZoomLevel, max: maxZoomLevel)
        
        // Apply sensitivity to deltaX and convert to angle delta
        let sensitivity: CGFloat = 0.5 // Reduced sensitivity for smoother control
        let angleDelta = -CGFloat(deltaX) * sensitivity // Correct direction
        
        // Calculate new angle and convert back to zoom
        let newAngle = currentAngle + angleDelta
        let boundedAngle = max(45.0, min(135.0, newAngle)) // Clamp to 45°-135° range
        let newZoomLevel = boundedAngle.zoomFromAngle(min: minZoomLevel, max: maxZoomLevel)
        
        let snappedZoomLevel = applyDragSnapping(newZoomLevel)
        zoomLevel = max(minZoomLevel, min(maxZoomLevel, snappedZoomLevel))
    }
    
    // Logarithmic distribution functions from ZoomWheel
    
    private func applyDragSnapping(_ targetZoom: CGFloat) -> CGFloat {
        let snapThreshold: CGFloat = 0.05 // Sensitivity for snapping during drag

        // Use only zoomSteps as snap points
        let snapPoints = zoomSteps.map { $0.zoom }

        // Find nearest snap point
        if let nearestSnap = snapPoints.min(by: { abs($0 - targetZoom) < abs($1 - targetZoom) }) {
            let distance = abs(nearestSnap - targetZoom)

            if distance < snapThreshold {
                // Trigger haptic feedback when snapping to a new zoom level
                if abs(nearestSnap - lastSnappedZoom) > 0.01 { // Avoid repeated feedback for same value
                    lastSnappedZoom = nearestSnap
                }
                
                // Smooth magnetic attraction to snap point
                let snapStrength: CGFloat = 0.2 // Strength of the magnetic effect
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
