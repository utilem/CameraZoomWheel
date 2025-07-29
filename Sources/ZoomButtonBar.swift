//
//  ZoomButtonBar.swift
//  CameraZoom
//
//  Created by Uwe Tilemann on 07.07.25.
//

import SwiftUI

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
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(zoomValues.enumerated()), id: \.offset) { index, zoomValue in
                Button(action: {
                    withAnimation {
                        selectedZoom = zoomValue.zoom
                    }
                }) {
                    Text(formatZoomValue(index))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(index == currentButtonIndex ? .yellow : .white)
                        .frame(width: 50, height: 34)
                        .scaleEffect(index == currentButtonIndex ? 0.9 : 1.0)
                        .background(
                            Circle()
                                .fill(index == currentButtonIndex ? Color.black.opacity(0.6) : Color.black.opacity(0.4))
                        )
                        .scaleEffect(index == currentButtonIndex ? 1.1 : 0.9)
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
    }
    
    var currentButtonIndex: Int {
        // Find the index of the largest value that is <= zoom
        for i in stride(from: zoomValues.count - 1, through: 0, by: -1) {
            if selectedZoom >= zoomValues[i].zoom {
                return i
            }
        }
        return 0
    }
    
    private func formatZoomValue(_ index: Int) -> String {
        let isCurrent = index == currentButtonIndex
        let value = isCurrent ? selectedZoom : zoomValues[index].zoom
        
        return Formatters.numberFormatter(value, digits: value.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 1, suffix: isCurrent ? "×" : "")
    }
}

