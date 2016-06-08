//
// Created by Nickolay Sheika on 6/8/16.
//

import Foundation


class BiggestFaceAnimationDataSource: AnimationDataSource {
    let animationDependencies: ImageAnimationDependencies


    init(animationDependencies: ImageAnimationDependencies) {
        self.animationDependencies = animationDependencies
    }

    func buildAnimationForImage(image: UIImage, forAnimationRect animationRect: CGRect) -> ImageAnimation? {
        return nil
    }

    private func detectBiggestFaceRectInImage(image: UIImage) -> CGRect? {
        let faceDetector: CIDetector = CIDetector(ofType: CIDetectorTypeFace,
                                                  context: nil,
                                                  options: [CIDetectorAccuracy: CIDetectorAccuracyLow])
        var ciImage = image.CIImage

        if ciImage == nil {
            ciImage = CIImage(CGImage: image.CGImage!)
        }

        let faces: NSArray = faceDetector.featuresInImage(ciImage!, options: nil)
        let biggestFaceRect = biggestFaceRectFromFaces(faces)
        return biggestFaceRect
    }

    private func biggestFaceRectFromFaces(faces: NSArray) -> CGRect? {
        var biggestArea: Double = 0.0
        var biggestFace: AnyObject? = nil
        for face in faces {
            let faceRect = face.bounds
            let area: Double = Double(faceRect.width * faceRect.height)
            if (area > biggestArea) {
                biggestArea = area
                biggestFace = face
            }
        }
        return biggestFace != nil ? biggestFace!.bounds : nil
    }

}