import CoreGraphics

struct TargetWindow {
    let id: CGWindowID
    let bounds: CGRect

    init?(appName: String, windowTitle: String) {
        guard let windows = CGWindowListCopyWindowInfo(.optionAll, kCGNullWindowID) as? [[String: Any]] else { return nil }
        guard let window = (windows.first {
            $0[kCGWindowOwnerName as String] as? String == appName &&
                $0[kCGWindowName as String] as? String == windowTitle}) else { return nil }
        guard let id = window[kCGWindowNumber as String] as? Int else { return nil }
        guard let rect = window[kCGWindowBounds as String] as? NSDictionary, let bounds = CGRect(dictionaryRepresentation: rect) else { return nil }
        self.id = CGWindowID(id)
        self.bounds = bounds
    }

    func captureBitmap(relativeBounds: CGRect? = nil) -> NSBitmapImageRep? {
        let rect = relativeBounds.map {$0.offsetBy(dx: bounds.minX, dy: bounds.minY)} ?? .null
        guard let capture = CGWindowListCreateImage(rect, .optionIncludingWindow, id, []) else { return nil }
        return NSBitmapImageRep(cgImage: capture)
    }

    func capture(relativeBounds: CGRect? = nil) -> NSImage? {
        guard let bitmap = captureBitmap(relativeBounds: relativeBounds) else { return nil }
        let image = NSImage(size: bitmap.size)
        image.addRepresentation(bitmap)
        return image
    }
}
