//
// Created by Nickolay Sheika on 6/13/16.
// Copyright (c) 2016 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import APKenBurnsView

class SelectModeViewController: UITableViewController {

    // MARK: - Private Variables

    private var dataSource: [String]!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = ["family1", "family2", "nature1", "nature2"]
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        var faceRecognitionMode: APKenBurnsViewFaceRecognitionMode = .None
        if segue.identifier == "Biggest" {
           faceRecognitionMode = .Biggest
        }
        if segue.identifier == "Group" {
            faceRecognitionMode = .Group
        }
        let destination = segue.destination as! KenBurnsViewController
        destination.faceRecoginitionMode = faceRecognitionMode
        destination.dataSource = dataSource
    }
    
}
