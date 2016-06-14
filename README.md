# APKenBurnsView

![APKenBurnsView](/images/apkenburnsview_cover.png)

[![Build Status](https://www.bitrise.io/app/226b97fe8ae35817.svg?token=tO-nUoKK1sFwQyoW9pkLcQ&branch=master)](https://www.bitrise.io/app/226b97fe8ae35817)
[![Version](https://img.shields.io/cocoapods/v/APKenBurnsView.svg?style=flat)](http://cocoapods.org/pods/APKenBurnsView)
[![License](https://img.shields.io/cocoapods/l/APKenBurnsView.svg?style=flat)](http://cocoapods.org/pods/APKenBurnsView)
[![Platform](https://img.shields.io/cocoapods/p/APKenBurnsView.svg?style=flat)](http://cocoapods.org/pods/APKenBurnsView)

## ***Ken Burns effect with face recognition!***

APKenBurnsView is UIView subclass which supports face recognition to beautifully animate people photos.


![APKenBurnsView](/images/demo.gif)


## Features
* Face recognition feature to beautifully animate people photos. 
* Totally random algorithm. No more hardcoded values!
* Memory efficient. Holds maximum of two UIImage pointers at any moment.
* Pausing animations done right. 
* Auto restart after entering background and returning back.
* A lot of animation customizations to fit your needs.

## Face Recognition

APKenBurnsView supports three modes for face recognition: 
* `None` - no face recognition, simple Ken Burns effect.
* `Biggest` - recognizes biggest face in image, if any then transition will start or finish (chosen randomly) in center of face rect.
* `Group` - recognizes all faces in image, if any then transition will start or finish (chosen randomly) in center of compound rect of all faces.


## Usage

Just simple interface. Provide data source class for UIImage's, setup all timings and run `startAnimations()`. No rocket science!

Data source should be ready to provide next image at the moment when APKenBurnsView calls `func nextImageForKenBurnsView(kenBurnsView: APKenBurnsView) -> UIImage?`. If there is no UIImage ready (still loading from network, etc.) then data source should return `nil` and APKenBurnsView will animate last image one more time. If you are loading your images from network you should consider some preloading mechanism.

Example of usage:
```swift
class MyViewController: UIViewController {
    // MARK: - Outlets 
    @IBOutlet weak var kenBurnsView: APKenBurnsView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        kenBurnsView.dataSource = self
        kenBurnsView.faceRecognitionMode = .Biggest
        
        kenBurnsView.scaleFactorDeviation = 0.5
        kenBurnsView.imageAnimationDuration = 5.0
        kenBurnsView.imageAnimationDurationDeviation = 1.0
        kenBurnsView.transitionAnimationDuration = 2.0
        kenBurnsView.transitionAnimationDurationDeviation = 1.0
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.kenBurnsView.startAnimations()
    }
}
    
extension KenBurnsViewController: APKenBurnsViewDataSource {
    func nextImageForKenBurnsView(kenBurnsView: APKenBurnsView) -> UIImage? {
        return /* Provide UIImage instance */
    }
}
```

## Example

To run the example project, clone the repo, and run pod install from the Example directory first.

## Requirements

- iOS 8.0 and higher
- ARC

## Installation

APKenBurnsView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'APKenBurnsView'
```

## Author

Nickolay Sheika, hawk.ukr@gmail.com

## Contacts

If you have improvements or concerns, feel free to post [an issue](https://github.com/Alterplay/APKenBurnsView/issues) and write details.

[Check out](https://github.com/Alterplay) all Alterplay's GitHub projects.
[Email us](mailto:hello@alterplay.com?subject=From%20GitHub%20APValidators) with other ideas and projects.

## License

APKenBurnsView is available under the MIT license. See the LICENSE file for more info.
