//
//  ZoomButtonBar.swift
//  CameraZoom
//
//  Created by Uwe Tilemann on 07.07.25.
//

import SwiftUI

// Button group representing a zoom range with multiple possible values
private struct ButtonGroup {
    let range: ClosedRange<CGFloat>
    let steps: [ZoomStep]
    let baseValue: CGFloat  // The "main" value for this group (e.g., 1.0, 2.0, 3.0)
    
    init(range: ClosedRange<CGFloat>, steps: [ZoomStep]) {
        self.range = range
        self.steps = steps.sorted { $0.zoom < $1.zoom }
        // Base value is the integer value in the range (1.0, 2.0, 3.0) or first value if < 1.0
        if range.lowerBound < 1.0 {
            self.baseValue = steps.first?.zoom ?? range.lowerBound
        } else {
            self.baseValue = floor(range.lowerBound)
        }
    }
}

public enum Formatters {
    public static func numberFormatter(_ number: Double, digits: Int = 1, suffix: String? = nil) -> String {
        let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 1
            formatter.maximumFractionDigits = 1
            return formatter
        }()
        formatter.positiveSuffix = suffix ?? ""
        formatter.maximumFractionDigits = digits
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }
}

public struct ZoomButtonBar: View {
    @Binding var selectedZoom: CGFloat
    let zoomValues: [ZoomStep]
    
    // Button groups based on zoom ranges
    private let buttonGroups: [ButtonGroup]
    
    // State for cycling through values in each group
    @State private var groupCycleIndices: [Int] = []
        
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    public init(selectedZoom: Binding<CGFloat>,
         zoomValues: [ZoomStep] = ZoomStep.zoomButtons
    ) {
        self._selectedZoom = selectedZoom
        self.zoomValues = zoomValues
        self.buttonGroups = Self.createButtonGroups(from: zoomValues)
        self._groupCycleIndices = State(initialValue: Array(repeating: 0, count: buttonGroups.count))
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(buttonGroups.enumerated()), id: \.offset) { groupIndex, group in
                Button(action: {
                    cycleToNextValue(in: groupIndex)
                }) {
                    Text(formatGroupValue(for: groupIndex))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(isGroupActive(groupIndex) ? .yellow : .white)
                        .frame(width: 50, height: 34)
                        .scaleEffect(isGroupActive(groupIndex) ? 0.9 : 1.0)
                        .background(
                            Circle()
                                .fill(isGroupActive(groupIndex) ? Color.black.opacity(0.6) : Color.black.opacity(0.4))
                        )
                        .scaleEffect(isGroupActive(groupIndex) ? 1.1 : 0.9)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedZoom)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.2))
                .likeGlass(Color.black.opacity(0.1))
        )
        .onAppear {
            updateCycleIndicesForCurrentZoom()
        }
        .onChange(of: selectedZoom) { _, _ in
            updateCycleIndicesForCurrentZoom()
        }
    }
    
    // MARK: - Button Group Creation
    
    private static func createButtonGroups(from zoomSteps: [ZoomStep]) -> [ButtonGroup] {
        var groups: [ButtonGroup] = []
        
        // Group 1: Ultra-wide (< 1.0)
        let ultraWideSteps = zoomSteps.filter { $0.zoom < 1.0 }
        if !ultraWideSteps.isEmpty {
            let minZoom = ultraWideSteps.map { $0.zoom }.min() ?? 0.5
            groups.append(ButtonGroup(range: minZoom...0.999, steps: ultraWideSteps))
        }
        
        // Group 2: 1x range (1.0 <= x < 2.0)
        let oneXSteps = zoomSteps.filter { $0.zoom >= 1.0 && $0.zoom < 2.0 }
        if !oneXSteps.isEmpty {
            groups.append(ButtonGroup(range: 1.0...1.999, steps: oneXSteps))
        }
        
        // Group 3: 2x range (2.0 <= x < 3.0)
        let twoXSteps = zoomSteps.filter { $0.zoom >= 2.0 && $0.zoom < 3.0 }
        if !twoXSteps.isEmpty {
            groups.append(ButtonGroup(range: 2.0...2.999, steps: twoXSteps))
        }
        
        // Group 4: 3x range (3.0 and higher)
        let threeXSteps = zoomSteps.filter { $0.zoom >= 3.0 }
        if !threeXSteps.isEmpty {
            let maxZoom = threeXSteps.map { $0.zoom }.max() ?? 3.0
            groups.append(ButtonGroup(range: 3.0...maxZoom, steps: threeXSteps))
        }
        
        return groups
    }
    
    // MARK: - Cycling Logic
    
    private func cycleToNextValue(in groupIndex: Int) {
        guard groupIndex < buttonGroups.count else { return }
        
        let group = buttonGroups[groupIndex]
        let isCurrentlyActive = isGroupActive(groupIndex)
        
        // Reset all other groups to their base values
        resetOtherGroupsToBaseValues(except: groupIndex)
        
        if !isCurrentlyActive {
            // First click on inactive button: go to base value
            if let baseIndex = group.steps.firstIndex(where: { $0.zoom == group.baseValue }) {
                groupCycleIndices[groupIndex] = baseIndex
                let baseZoom = group.steps[baseIndex].zoom
                withAnimation {
                    selectedZoom = baseZoom
                }
            }
        } else {
            // Button is active: cycle to next value
            let currentIndex = groupCycleIndices[groupIndex]
            let nextIndex = (currentIndex + 1) % group.steps.count
            
            groupCycleIndices[groupIndex] = nextIndex
            
            let nextZoom = group.steps[nextIndex].zoom
            withAnimation {
                selectedZoom = nextZoom
            }
        }
    }
    
    private func resetOtherGroupsToBaseValues(except activeGroupIndex: Int) {
        for (groupIndex, group) in buttonGroups.enumerated() {
            guard groupIndex != activeGroupIndex else { continue }
            
            // Find the index of the base value (1.0, 2.0, 3.0) in this group
            if let baseIndex = group.steps.firstIndex(where: { $0.zoom == group.baseValue }) {
                groupCycleIndices[groupIndex] = baseIndex
            } else {
                // Fallback to first step if base value not found
                groupCycleIndices[groupIndex] = 0
            }
        }
    }
    
    private func updateCycleIndicesForCurrentZoom() {
        for (groupIndex, group) in buttonGroups.enumerated() {
            if group.range.contains(selectedZoom) {
                // Find the step in this group that matches or is closest to selectedZoom
                if let stepIndex = group.steps.firstIndex(where: { abs($0.zoom - selectedZoom) < 0.01 }) {
                    groupCycleIndices[groupIndex] = stepIndex
                } else {
                    // For values without exact ZoomStep match (e.g., 9.6 in 3x group), 
                    // find the closest step or default to first step
                    let closestStepIndex = group.steps.enumerated().min(by: { 
                        abs($0.element.zoom - selectedZoom) < abs($1.element.zoom - selectedZoom) 
                    })?.offset ?? 0
                    groupCycleIndices[groupIndex] = closestStepIndex
                }
                break
            }
        }
    }
    
    // MARK: - UI Helper Methods
    
    private func isGroupActive(_ groupIndex: Int) -> Bool {
        guard groupIndex < buttonGroups.count else { return false }
        return buttonGroups[groupIndex].range.contains(selectedZoom)
    }
    
    private func formatGroupValue(for groupIndex: Int) -> String {
        guard groupIndex < buttonGroups.count && groupIndex < groupCycleIndices.count else { return "" }
        
        let group = buttonGroups[groupIndex]
        let cycleIndex = groupCycleIndices[groupIndex]
        let currentStep = group.steps[cycleIndex]
        
        let isActive = isGroupActive(groupIndex)
        let value = isActive ? selectedZoom : currentStep.zoom
        
        return Formatters.numberFormatter(value, digits: value.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 1, suffix: isActive ? "×" : "")
    }
}

