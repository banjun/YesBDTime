import Cocoa
import NorthLayout
import Ikemen

final class DebugView: NSView, NSTableViewDataSource, NSTableViewDelegate, NSFilePromiseProviderDelegate {
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
        tv.setDraggingSourceOperationMask(.copy, forLocal: false)
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

    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        guard let png = NSBitmapImageRep(cgImage: boxes[row].image.cgImage(forProposedRect: nil, context: nil, hints: nil)!).representation(using: .png, properties: [:]) else { return nil }
        return NSFilePromiseProvider(fileType: "public.data", delegate: self) ※ {
            $0.userInfo = [
                "name": "\(boxes[row].predicted).png",
                "png": png]}
    }

    func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, fileNameForType fileType: String) -> String {
        return (filePromiseProvider.userInfo as! [String: Any])["name"] as! String
    }

    func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, writePromiseTo url: URL, completionHandler: @escaping (Error?) -> Void) {
        do {
            let png = (filePromiseProvider.userInfo as! [String: Any])["png"] as! Data
            try png.write(to: url)
            completionHandler(nil)
        } catch {
            completionHandler(error)
        }
    }
}
