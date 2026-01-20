# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2026-01-20

### Changed
- Updated to Swift 6 with full strict concurrency checking
- Minimum Swift version is now 6.0
- Added explicit `Sendable` conformance to `ZoomWheelConfiguration`
- Timer callbacks now use `MainActor.assumeIsolated` for proper actor isolation

### Fixed
- Corrected magnetic snapping strength documentation (0.2 instead of 0.25)

## [1.0.0] - 2024-09-02

### Added
- Initial release
- `ZoomControl` - Main orchestrating component with dual interface modes
- `ZoomWheel` - Circular zoom slider with logarithmic distribution
- `ZoomButtonBar` - Intelligent discrete zoom buttons with cycling behavior
- `ZoomStep` - Data model for zoom level configuration
- `ZoomWheelConfiguration` - Centralized configuration system
- Device-aware zoom steps via `AVCaptureDevice.zoomSteps` extension
- Magnetic snapping system for smooth interaction
- Support for iOS 17+

[Unreleased]: https://github.com/utilem/CameraZoomWheel/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/utilem/CameraZoomWheel/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/utilem/CameraZoomWheel/releases/tag/v1.0.0
