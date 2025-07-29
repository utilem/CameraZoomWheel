//
//  ContentView.swift
//  ZoomWheelDemo
//
//  Created by Uwe Tilemann on 25.07.25.
//

import SwiftUI

import CameraZoomWheel

struct ContentView: View {
    @State private var zoomLevel: CGFloat = 1
    @State private var zoomSteps: [ZoomStep] = ZoomStep.defaultSteps
    
#if !targetEnvironment(simulator)
    @State private var viewModel = ViewModel()
#endif
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
#if targetEnvironment(simulator)
                LinearGradient(
                    gradient: Gradient(colors: [
                        .white,
                        .black.opacity(0.6)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                Image(systemName: "applelogo")
                    .font(.system(size: 60))
                    .foregroundColor(.black)
                    .scaleEffect(zoomLevel)
#else
                CameraView(image: $viewModel.currentFrame)
                    .onChange(of: zoomLevel) { _, newValue in
                        viewModel.zoomValue = newValue
                    }
#endif
                VStack {
                    Spacer()
                    
                    ZoomControl(zoomLevel: $zoomLevel, steps: zoomSteps)
                }
            }
            Rectangle()
                .fill(Color.yellow)
                .frame(height: 152)
        }
        .task {
#if !targetEnvironment(simulator)
            zoomSteps = viewModel.zoomSteps
#endif
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
