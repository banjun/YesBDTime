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

import NorthLayout
import Ikemen

final class DebugView: NSView, NSTableViewDataSource, NSTableViewDelegate {
    var boxes: [(rect: NSRect, image: NSImage, predicted: Int64)] = [] {
        didSet {digitsView.reloadData()}
    }
    private(set) lazy var textImageView: NSImageView = .init()
    private lazy var digitsView: NSTableView = .init() ※ { tv in
        tv.addTableColumn(imageColumn)
        tv.addTableColumn(digitColumn)
        tv.dataSource = self
        tv.delegate = self
        tv.target = self
    }

    private lazy var imageColumn: NSTableColumn = .init(identifier: .init("Image")) ※ { c in
        c.title = "Image"
    }
    private lazy var digitColumn: NSTableColumn = .init(identifier: .init("Digit")) ※ { c in
        c.title = "Digit"
    }

    init() {
        super.init(frame: .zero)
        let autolayout = northLayoutFormat([:], [
            "textImage": textImageView,
            "digitsTable": NSScrollView() ※ {$0.documentView = digitsView}])
        autolayout("H:|[textImage]|")
        autolayout("H:|[digitsTable]|")
        autolayout("V:|[textImage]-[digitsTable]|")
    }

    required init?(coder decoder: NSCoder) {fatalError()}

    func numberOfRows(in tableView: NSTableView) -> Int {
        return boxes.count
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 48
    }

    func tableView(_ tableView: NSTableView, dataCellFor tableColumn: NSTableColumn?, row: Int) -> NSCell? {
        switch tableColumn {
        case imageColumn?: return NSCell(imageCell: boxes[row].image)
        case digitColumn?: return NSCell(textCell: "")
        default: return nil
        }
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        switch tableColumn {
        case imageColumn?: return boxes[row].image
        case digitColumn?: return String(boxes[row].predicted)
        default: return nil
        }
    }
}

