# ZoomWheelDemo

A SwiftUI example app demonstrating the **CameraZoomWheel** package functionality. This app showcases an advanced camera zoom control interface with both discrete button controls and a continuous circular slider.

## Features

- **Dual Zoom Interface**: Switch between button bar and circular slider controls
- **Real Camera Integration**: Uses live camera feed on physical devices
- **Simulator Support**: Shows scaled Apple logo for testing in simulator
- **Smooth Animations**: Seamless transitions between zoom modes
- **Logarithmic Zoom Distribution**: Natural zoom progression from 0.5× to 10×

## Components Demonstrated

### ZoomControl
The main component from the CameraZoomWheel package that orchestrates:
- Button bar for quick zoom level access (0.5×, 1×, 2×, 3×)
- Circular slider with magnetic snapping to zoom steps
- Long-press gesture to switch between modes
- Smooth drag-based zoom control

### Camera Integration
- **On Device**: Live camera preview with real-time zoom control
- **In Simulator**: Visual demo with scalable Apple logo

## Requirements

- iOS 17.0+
- Swift 6.0+
- Xcode 16.0+

## Usage

1. **Quick Zoom**: Tap any zoom button (0.5×, 1×, 2×, 3×) for instant zoom
2. **Continuous Zoom**: Long-press any zoom button to activate the circular slider
3. **Slider Control**: Drag along the circular arc for precise zoom control
4. **Magnetic Snapping**: The slider automatically snaps to common zoom levels
5. **Auto-Hide**: The slider automatically hides after 1 second of inactivity

## Camera Components Attribution

The camera functionality in this demo app (CameraManager, ViewModel, and CameraView) is based on the excellent work from:

**Source**: [Camera capture setup in SwiftUI](https://github.com/create-with-swift/Camera-capture-setup-in-SwiftUI)  
**Author**: Create with Swift  
**License**: MIT

We extend our gratitude to the Create with Swift team for providing this solid foundation for SwiftUI camera integration.

## Project Structure

```
ZoomWheelDemo/
├── ZoomWheelDemoApp.swift      # App entry point
├── ContentView.swift           # Main demo view
├── CameraManager.swift         # Camera session management
├── ViewModel.swift             # Camera view model
├── CameraView.swift            # Camera preview view
└── Assets.xcassets/           # App icons and assets
```

## Installation

This example app is included with the CameraZoomWheel Swift Package. To run:

1. Open `ZoomWheelDemo.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run (⌘+R)

For device testing with live camera, ensure:
- Camera permissions are granted
- Use a physical iOS device (camera not available in simulator)

## Integration

To integrate CameraZoomWheel into your own project:

```swift
import CameraZoomWheel

struct YourView: View {
    @State private var zoomLevel: CGFloat = 1.0
    @State private var zoomSteps: [ZoomStep] = ZoomStep.defaultSteps
    
    var body: some View {
        ZoomControl(zoomLevel: $zoomLevel, steps: zoomSteps)
    }
}
```

## License

This example app follows the same license as the CameraZoomWheel package.