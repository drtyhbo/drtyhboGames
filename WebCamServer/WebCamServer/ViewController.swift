//
//  ViewController.swift
//  WebCamServer
//
//  Created by Andreas Binnewies on 12/17/15.
//  Copyright © 2015 drtyhbo. All rights reserved.
//

import AVFoundation
import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var webcamComboBox: NSComboBox!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

extension ViewController: NSComboBoxDataSource {
    func numberOfItemsInComboBox(aComboBox: NSComboBox) -> Int {
        return AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).count
    }

    func comboBox(aComboBox: NSComboBox, objectValueForItemAtIndex index: Int) -> AnyObject {
        return AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)[index].localizedName!!
    }
}