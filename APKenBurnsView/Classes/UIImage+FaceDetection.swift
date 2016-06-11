//
// Created by Nickolay Sheika on 6/10/16.
//

import Foundation
import UIKit
import QuartzCore

extension UIImage {

    // MARK: - Public

    public func biggestFaceRect() -> CGRect? {
        let faces = detectFaces()

        var biggestArea: Double = 0.0
        var biggestFace: CIFaceFeature? = nil
        for face in faces {
            let faceRect = face.bounds
            let area: Double = Double(faceRect.width * faceRect.height)
            if (area > biggestArea) {
                biggestArea = area
                biggestFace = face
            }
        }

        guard let biggestFaceUnwrapped = biggestFace else {
            return nil
        }

        let faceBounds = biggestFaceUnwrapped.bounds

        let scaledFaceRect = faceBounds.scaledRect(1 / scale)
        let convertedFaceRect = CGRectMake(scaledFaceRect.origin.x,
                                           size.height - scaledFaceRect.origin.y - scaledFaceRect.size.height,
                                           scaledFaceRect.size.width,
                                           scaledFaceRect.size.height)
        return convertedFaceRect
    }

    public func groupFacesRect() -> CGRect? {
        let faces = allFacesRects()

        guard faces.count > 0 else {
            return nil
        }

        let first = faces.first!
        var topLeftPoint: CGPoint = CGPointMake(CGRectGetMinX(first), CGRectGetMinY(first))
        var bottomRightPoint: CGPoint = CGPointMake(CGRectGetMaxX(first), CGRectGetMaxY(first))
        for faceRect in faces {
            if CGRectGetMinX(faceRect) < topLeftPoint.x {
                topLeftPoint.x = CGRectGetMinX(faceRect)
            }
            if CGRectGetMinY(faceRect) < topLeftPoint.y {
                topLeftPoint.y = CGRectGetMinY(faceRect)
            }
            if CGRectGetMaxX(faceRect) > bottomRightPoint.x {
                bottomRightPoint.x = CGRectGetMaxX(faceRect)
            }
            if CGRectGetMaxY(faceRect) > bottomRightPoint.y {
                bottomRightPoint.y = CGRectGetMaxY(faceRect)
            }
        }
        let groupRect = CGRectMake(topLeftPoint.x,
                                   topLeftPoint.y,
                                   bottomRightPoint.x - topLeftPoint.x,
                                   bottomRightPoint.y - topLeftPoint.y)
        return groupRect
    }

    func allFacesRects() -> [CGRect] {
        let faces = detectFaces()
        guard faces.count > 0 else {
            return []
        }

        var result = [CGRect]()
        for face in faces {
            let faceRect = face.bounds
            let scaledFaceRect = faceRect.scaledRect(1 / scale)

            // convert from core graphics coordinate space
            let convertedFaceRect = CGRectMake(scaledFaceRect.origin.x,
                                               size.height - scaledFaceRect.origin.y - scaledFaceRect.size.height,
                                               scaledFaceRect.size.width,
                                               scaledFaceRect.size.height)
            result.append(convertedFaceRect)
        }
        return result
    }

    // MARK: - Private

    private func detectFaces() -> [CIFaceFeature] {
        let faceDetector: CIDetector = CIDetector(ofType: CIDetectorTypeFace,
                                                  context: nil,
                                                  options: [CIDetectorAccuracy: CIDetectorAccuracyLow])
        var ciImage = self.CIImage

        if ciImage == nil {
            guard let cgImage = self.CGImage else {
                return []
            }
            ciImage = UIKit.CIImage(CGImage: cgImage)
        }

        let faces = faceDetector.featuresInImage(ciImage!, options: nil) as! [CIFaceFeature]
        return faces
    }
}