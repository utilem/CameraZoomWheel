import CoreGraphics
import Foundation

extension CGFloat {
    
    func toZoomAngle(min: CGFloat = 0.5, max: CGFloat = 10.0) -> CGFloat {
        let logMin = log(min)
        let logMax = log(max)
        let logZoom = log(self)
        
        let progress = (logZoom - logMin) / (logMax - logMin)
        return 45 + progress * 90 // From 45° to 135°
    }
    
    func zoomFromAngle(min: CGFloat = 0.5, max: CGFloat = 10.0) -> CGFloat {
        let progress = (self - 45) / 90.0 // Normalize from 45°-135° to 0-1
        
        let logMin = log(min)
        let logMax = log(max)
        let logZoom = logMin + progress * (logMax - logMin)
        
        return exp(logZoom)
    }
}