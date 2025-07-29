# CameraZoomWheel

A SwiftUI package providing advanced camera zoom controls with both discrete button and continuous wheel interfaces.

## Features

- **Dual Interface**: Switch between zoom buttons and circular zoom wheel via long press
- **Logarithmic Distribution**: Natural zoom progression across 90° arc  
- **Magnetic Snapping**: Smooth attraction to common zoom levels during interaction
- **Device Awareness**: Adapts to actual camera capabilities (real device vs simulator)
- **Customizable**: Configurable zoom steps, ranges, and styling
- **Modern SwiftUI**: Built with SwiftUI exclusively, supports iOS 17+

## Screenshots

*Add screenshots showing button mode, wheel mode, and transitions*

## Installation

### Swift Package Manager

Add ZoomControl to your project via Xcode:
1. File → Add Package Dependencies
2. Enter URL: `https://github.com/utilem/CameraZoomWheel`
3. Select version and add to target

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/utilem/CameraZoomWheel", from: "1.0.0")
]
```

## Usage

### Basic Implementation

```swift
import SwiftUI
import CameraZoomWheel

struct CameraView: View {
    @State private var zoomLevel: Double = 1.0
    
    var body: some View {
        ZStack {
            // Your camera preview here
            CameraPreview()
            
            VStack {
                Spacer()
                
                ZoomControl(
                    zoomLevel: $zoomLevel,
                    steps: ZoomStep.defaultSteps
                )
            }
        }
    }
}
```

### Custom Zoom Steps

```swift
let customSteps: [ZoomStep] = [
    ZoomStep(zoom: 0.5, focalLength: "13mm", type: .focalLength),
    ZoomStep(zoom: 1.0, focalLength: "24mm", type: .focalLength),
    ZoomStep(zoom: 2.0, focalLength: "48mm", type: .value),
    ZoomStep(zoom: 5.0, type: .value)
]

ZoomControl(zoomLevel: $zoomLevel, steps: customSteps)
```

### Device-Specific Configuration

The package includes an `AVCaptureDevice` extension that automatically adapts zoom steps to the actual camera capabilities of the device:

```swift
import AVFoundation
import CameraZoomWheel

// Get camera device
guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, 
                                          for: .video, 
                                          position: .back) else { return }

// Use device-specific zoom steps - automatically adapts to:
// - Ultra-wide availability (< 1.0x zoom)
// - Telephoto ranges (2x, 3x, 5x based on device capabilities)
// - Maximum zoom limits
ZoomControl(zoomLevel: $zoomLevel, steps: camera.zoomSteps)
```

**What `camera.zoomSteps` provides:**
- **Ultra-wide detection**: Adds 0.5× (13mm) if `minAvailableVideoZoomFactor < 1.0`
- **Main camera**: Always includes 1× (24mm)
- **Telephoto adaptation**: Progressively adds 2× (48mm), 3× (77mm), 5× (120mm) based on `maxAvailableVideoZoomFactor`
- **Maximum zoom**: Caps at 10× (240mm) for optimal user experience

This ensures your zoom control perfectly matches what the device camera can actually achieve, providing a native iOS camera app experience.

## Components

### ZoomControl
Main orchestrating component that manages both button and wheel modes.

**Properties:**
- `zoomLevel: Binding<Double>` - Current zoom level
- `steps: [ZoomStep]` - Available zoom levels and display configuration

**Behavior:**  
- **Tap**: Use zoom buttons for quick selection
- **Long Press**: Activate zoom wheel for continuous control
- **Drag**: Adjust zoom level on active wheel
- **Auto-hide**: Wheel disappears after 1 second of inactivity

### ZoomWheel  
Advanced circular zoom slider with logarithmic distribution.

**Features:**
- 90° arc from 45° to 135° 
- Logarithmic zoom progression for natural feel
- Dynamic tick marks and zoom step indicators
- Magnetic snapping during interaction

### ZoomButtonBar
Intelligent discrete zoom buttons that adapt to available ZoomSteps.

**Smart Button Grouping:**
- **Ultra-wide Button**: All ZoomSteps < 1.0 (e.g., 0.5×)
- **1× Button**: ZoomSteps 1.0 ≤ x < 2.0 (e.g., 1.0, 1.2, 1.5)
- **2× Button**: ZoomSteps 2.0 ≤ x < 3.0 (e.g., 2.0, 2.5)
- **3× Button**: All ZoomSteps ≥ 3.0 (e.g., 3.0, 5.0, 10.0) - acts as "Tele+" button
- **Slider Integration**: 3× button shows current zoom value even for intermediate values (e.g., 9.6×)

**Cycling Behavior:**
- **First tap on inactive button**: Goes to base value (1.0, 2.0, 3.0)
- **Subsequent taps**: Cycles through all values in that group
- **Group switching**: Other buttons reset to their base values
- **Example**: 1× button cycles: 1.0 → 1.2 → 1.5 → 1.0

**Features:**
- Animated selection with scaling and color changes
- Automatically adapts to available ZoomSteps
- Intelligent grouping prevents UI clutter

### ZoomStep
Data model for zoom level configuration.

```swift
struct ZoomStep {
    let zoom: Double
    let focalLength: String?
    let type: DisplayType
    
    enum DisplayType {
        case dot         // Simple dot indicator
        case value       // Shows zoom value (e.g., "2×")  
        case focalLength // Shows focal length (e.g., "24mm")
    }
}
```

## Architecture

### Animation System
- **Simplified Architecture**: Single animation source prevents conflicts
- **Magnetic Snapping**: Two-layer system for smooth interaction
- **Conflict Prevention**: Careful animation timing prevents "Invalid sample" errors

### Gesture Handling
- **Seamless Transitions**: Long press flows directly into drag gesture
- **Relative Delta System**: Smooth movement between consecutive drag events
- **Direction Consistency**: Reliable left/right drag behavior

### Technical Details
- **Logarithmic Distribution**: `zoom = exp(logMin + progress * (logMax - logMin))`
- **Chord-Height Formula**: `r = (chord² / (8 * height)) + (height / 2)`
- **Animation Timing**: 0.3s easeInOut for all transitions

## Demo App

The package includes a comprehensive demo showing:
- **Real Device Integration**: Live camera preview with zoom control on physical devices
- **Simulator Support**: Visual demo with scalable Apple logo for testing  
- **Permission Handling**: Proper camera access flow
- **Device Detection**: Automatic real/simulator mode switching

### Camera Components Attribution

The demo app's camera functionality is based on excellent work from:
- **Source**: [Camera capture setup in SwiftUI](https://github.com/create-with-swift/Camera-capture-setup-in-SwiftUI)
- **Components**: CameraManager, ViewModel, CameraView
- **License**: MIT

Run the demo:
```bash
cd Example/ZoomWheelDemo
# Open ZoomWheelDemo.xcodeproj in Xcode and run
```

## Requirements

- iOS 17.0+
- Swift 6.2+
- Xcode 16.0+

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by iOS Camera app zoom interface
- Built with modern SwiftUI patterns and best practices
- Logarithmic zoom distribution for natural camera feel
