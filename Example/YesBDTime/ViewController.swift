//
//  ViewController.swift
//  YesBDTime
//
//  Created by banjun on 06/24/2018.
//  Copyright (c) 2018 banjun. All rights reserved.
//

import Cocoa
import YesBDTime

class ViewController: NSViewController {
    let ybt = YesBDTime()

    override func viewDidLoad() {
        super.viewDidLoad()

        ybt.callback = { t in
            NSLog("%@", "BD Time = \(t)")
        }
        ybt.capture(repeatedlyWith: 1)
    }
}

