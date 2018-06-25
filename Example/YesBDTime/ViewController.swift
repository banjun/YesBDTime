//
//  ViewController.swift
//  YesBDTime
//
//  Created by banjun on 06/24/2018.
//  Copyright (c) 2018 banjun. All rights reserved.
//

import Cocoa
import YesBDTime
import NorthLayout

class ViewController: NSViewController {
    let ybt = YesBDTime()
    let debugView = DebugView()

    override func viewDidLoad() {
        super.viewDidLoad()

        let debug = true
        if !debug {
            ybt.callback = { t in
                NSLog("%@", "BD Time = \(t)")
            }
            ybt.capture(repeatedlyWith: 1)
        } else {
            // for debugging YesBDTime
            let autolayout = view.northLayoutFormat([:], ["debug": debugView])
            autolayout("H:|-[debug]-|")
            autolayout("V:|-[debug]-|")

            ybt.debugCapture(repeatedlyWith: 1) { [weak self] image, boxes in
                // NSLog("%@", "image = \(image), boxes = \(boxes)")
                self?.debugView.textImageView.image = image
                self?.debugView.boxes = boxes
            }
        }
    }
}
