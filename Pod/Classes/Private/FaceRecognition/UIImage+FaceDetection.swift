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

        let scaledFaceRect = faceBounds.scaledRect(scale: 1 / scale)
        let convertedFaceRect = CGRect(x: scaledFaceRect.origin.x,
                                       y: size.height - scaledFaceRect.origin.y - scaledFaceRect.size.height,
                                       width:  scaledFaceRect.size.width,
                                       height: scaledFaceRect.size.height)
        return convertedFaceRect
    }

    public func groupFacesRect() -> CGRect? {
        let faces = allFacesRects()

        guard faces.count > 0 else {
            return nil
        }

        let first = faces.first!
        var topLeftPoint: CGPoint = CGPoint(x: first.minX, y: first.minY)
        var bottomRightPoint: CGPoint = CGPoint(x: first.maxX, y: first.maxY)
        for faceRect in faces {
            if faceRect.minX < topLeftPoint.x {
                topLeftPoint.x = faceRect.minX
            }
            if faceRect.minY < topLeftPoint.y {
                topLeftPoint.y = faceRect.minY
            }
            if faceRect.maxX > bottomRightPoint.x {
                bottomRightPoint.x = faceRect.maxX
            }
            if faceRect.maxY > bottomRightPoint.y {
                bottomRightPoint.y = faceRect.maxY
            }
        }
        let groupRect = CGRect(x: topLeftPoint.x,
                               y: topLeftPoint.y,
                               width: bottomRightPoint.x - topLeftPoint.x,
                               height: bottomRightPoint.y - topLeftPoint.y)
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
            let scaledFaceRect = faceRect.scaledRect(scale: 1 / scale)

            // convert from core graphics coordinate space
            let convertedFaceRect = CGRect(x: scaledFaceRect.origin.x,
                                           y: size.height - scaledFaceRect.origin.y - scaledFaceRect.size.height,
                                           width: scaledFaceRect.size.width,
                                           height: scaledFaceRect.size.height)
            result.append(convertedFaceRect)
        }
        return result
    }

    // MARK: - Private

    private func detectFaces() -> [CIFaceFeature] {
        let faceDetector: CIDetector = CIDetector(ofType: CIDetectorTypeFace,
                                                  context: nil,
                                                  options: [CIDetectorAccuracy: CIDetectorAccuracyLow])!
        var ciImage = self.ciImage

        if ciImage == nil {
            guard let cgImage = self.cgImage else {
                return []
            }

            ciImage = UIKit.CIImage(cgImage: cgImage)
        }

        let faces = faceDetector.features(in: ciImage!, options: nil) as! [CIFaceFeature]
        return faces
    }
}
