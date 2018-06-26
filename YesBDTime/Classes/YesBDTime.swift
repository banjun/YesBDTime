import Foundation

public final class YesBDTime {
    public var callback: ((TimeInterval) -> ())?
    let appName: String
    let windowTitle: String
    let relativeBounds: CGRect
    var timer: Timer?

    public init(appName: String = "Mac Blu-ray Player", windowTitle: String = "Mac Blu-ray Player", relativeBounds: CGRect = CGRect(x: -1, y: 64, width: 45, height: 12)) {
        self.appName = appName
        self.windowTitle = windowTitle
        self.relativeBounds = relativeBounds
    }

    private func setupTimer(interval: TimeInterval, block: @escaping () -> Void) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) {_ in block()}
    }

    public func capture(repeatedlyWith interval: TimeInterval) {
        setupTimer(interval: interval) {[weak self] in self?.capture()}
    }

    public func capture() {
        guard let callback = callback,
            let image = captureImage() else { return }
        ocr(image: image, callback: callback)
    }

    public func debugCapture(repeatedlyWith interval: TimeInterval, callback: @escaping (NSImage, [(NSRect, NSImage, Int64)]) -> Void) {
        setupTimer(interval: interval) {[weak self] in self?.debugCapture(callback)}
    }

    public func debugCapture(_ callback: @escaping (NSImage, [(NSRect, NSImage, Int64)]) -> Void) {
        guard let image = captureImage() else { return }
        ocr(image: image, callback: {_ in}, debugCallback: callback)
    }

    private func captureImage() -> NSImage? {
        guard let player = TargetWindow(appName: appName, windowTitle: windowTitle),
            let image = player.capture(relativeBounds: CGRect(
                x: relativeBounds.minX,
                y: player.bounds.height - relativeBounds.height - relativeBounds.minY,
                width: relativeBounds.width,
                height: relativeBounds.height)) else { return nil }
        return image
    }
}
