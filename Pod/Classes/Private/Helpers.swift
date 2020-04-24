//
// Created by Nickolay Sheika on 6/12/16.
//

import Foundation


extension CGSize {
    func scaledSize(scale: CGFloat) -> CGSize {
        return CGSize(width: width * scale, height: height * scale)
    }
}


extension CGRect {
    func scaledRect(scale: CGFloat) -> CGRect {
    
    
        
        return CGRect(x: self.minX * scale,
                      y: self.minY * scale,
                      width: self.width * scale,
                      height: self.height * scale)
    }

    func center() -> CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }

    init(center: CGPoint, size: CGSize) {
        self = CGRect(x: center.x - (size.width / 2), y: center.y - (size.height / 2), width: size.width, height: size.height)
    }
}
