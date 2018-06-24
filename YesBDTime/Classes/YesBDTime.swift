import Foundation

public final class YesBDTime {
    public var callback: ((TimeInterval) -> ())?
    let appName: String
    let windowTitle: String
    var timer: Timer?

    public init(appName: String = "Mac Blu-ray Player", windowTitle: String = "Mac Blu-ray Player") {
        self.appName = appName
        self.windowTitle = windowTitle
    }

    public func capture(repeatedlyWith interval: TimeInterval) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.capture()
        }
    }

    public func capture() {
        guard let callback = callback,
            let player = TargetWindow(appName: appName, windowTitle: windowTitle),
            let image = player.capture(relativeBounds: CGRect(x: 0, y: player.bounds.height - 12 - 64, width: 45, height: 12)) else { return }
        ocr(image: image, callback: callback)
    }
}
