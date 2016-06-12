//
// Created by Nickolay Sheika on 6/12/16.
//

import Foundation


extension CGSize {
    func scaledSize(scale: CGFloat) -> CGSize {
        return CGSizeMake(width * scale, height * scale)
    }
}


extension CGRect {
    func scaledRect(scale: CGFloat) -> CGRect {
        return CGRectMake(CGRectGetMinX(self) * scale,
                          CGRectGetMinY(self) * scale,
                          CGRectGetWidth(self) * scale,
                          CGRectGetHeight(self) * scale)
    }

    func center() -> CGPoint {
        return CGPointMake(CGRectGetMidX(self), CGRectGetMidY(self))
    }

    init(center: CGPoint, size: CGSize) {
        self = CGRectMake(center.x - (size.width / 2), center.y - (size.height / 2), size.width, size.height)
    }
}