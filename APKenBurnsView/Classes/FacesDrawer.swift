//
// Created by Nickolay Sheika on 6/11/16.
//

import Foundation
import UIKit

protocol FacesDrawerProtocol {
    func drawFacesInView(view: UIView, image: UIImage)
    func cleanUpForView(view: UIView)
}


class FacesDrawer: FacesDrawerProtocol {

    // MARK: - Public Variables

    var faceColor: UIColor = UIColor.redColor()
    var faceAlpha: CGFloat = 0.2

    // MARK: - Private Variables

    private var facesViews = [Int: [UIView]]()

    // MARK: - Public

    func drawFacesInView(view: UIView, image: UIImage) {
        cleanUpForView(view)

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let allFacesRects = image.allFacesRects()

            dispatch_async(dispatch_get_main_queue()) {
                guard allFacesRects.count > 0 else {
                    return
                }

                self.facesViews[view.hashValue] = []

                let viewPortSize = view.bounds
                let imageCenter = CGPointMake(viewPortSize.size.width / 2, viewPortSize.size.height / 2)
                let imageFrame = CGRect(center: imageCenter, size: image.size)

                for faceRect in allFacesRects {
                    let faceRectConverted = self.convertFaceRect(faceRect, inImageCoordinates: imageFrame.origin)

                    let faceView = self.buildFaceViewWithFrame(faceRectConverted)
                    self.facesViews[view.hashValue]!.append(faceView)

                    view.addSubview(faceView)
                }
            }
        }
    }

    func cleanUpForView(view: UIView) {
        guard let facesForView = facesViews[view.hashValue] else {
            return
        }

        for faceView in facesForView {
            faceView.removeFromSuperview()
        }
        facesViews[view.hashValue] = nil
    }

    // MARK: - Private

    private func convertFaceRect(faceRect: CGRect, inImageCoordinates imageOrigin: CGPoint) -> CGRect {
        let faceRectConvertedX = imageOrigin.x + faceRect.origin.x
        let faceRectConvertedY = imageOrigin.y + faceRect.origin.y
        let faceRectConverted = CGRectIntegral(CGRectMake(faceRectConvertedX,
                                                          faceRectConvertedY,
                                                          faceRect.size.width,
                                                          faceRect.size.height))
        return faceRectConverted
    }

    private func buildFaceViewWithFrame(frame: CGRect) -> UIView {
        let faceView = UIView(frame: frame)
        faceView.translatesAutoresizingMaskIntoConstraints = false
        faceView.backgroundColor = faceColor
        faceView.alpha = faceAlpha
        return faceView
    }
}
