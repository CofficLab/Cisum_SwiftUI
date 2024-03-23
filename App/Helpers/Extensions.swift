import Foundation
import OSLog
import SwiftUI
#if os(iOS)
    import UIKit
#endif

extension DateComponentsFormatter {
    static let abbreviated: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()

        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated

        return formatter
    }()

    static let positional: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()

        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad

        return formatter
    }()
}

extension Logger {
    static let loggingSubsystem: String = AppConfig.id

    static let databaseManager = Logger(subsystem: Self.loggingSubsystem, category: "DatabaseManager")
    static let audioManager = Logger(subsystem: Self.loggingSubsystem, category: "AudioManger")
    static let wild = Logger(subsystem: Self.loggingSubsystem, category: "Wild")
    static let app = Logger(subsystem: Self.loggingSubsystem, category: "App")
    static let audioListModel = Logger(subsystem: Self.loggingSubsystem, category: "AudioListModel")
    static let mediaPlayerManager = Logger(subsystem: Self.loggingSubsystem, category: "MediaPlayerManager")
    static let databaseModel = Logger(subsystem: Self.loggingSubsystem, category: "DatabaseModel")
    static let nodeDetail = Logger(subsystem: Self.loggingSubsystem, category: "NodeDetail")
    static let remoteNode = Logger(subsystem: Self.loggingSubsystem, category: "RemoteNode")
    static let remoteBody = Logger(subsystem: Self.loggingSubsystem, category: "RemoteBody")
    static let rootNode = Logger(subsystem: Self.loggingSubsystem, category: "RootNode")
    static let cloudKit = Logger(subsystem: Self.loggingSubsystem, category: "CloudKit")
    static let webView = Logger(subsystem: Self.loggingSubsystem, category: "WebView")
    static let persistence = Logger(subsystem: Self.loggingSubsystem, category: "Persistance")
    static let sideRow = Logger(subsystem: Self.loggingSubsystem, category: "SideRow")
    static let ui = Logger(subsystem: Self.loggingSubsystem, category: "UI")
    static let manager = Logger(subsystem: Self.loggingSubsystem, category: "Manager")
}

#if os(iOS)
    extension UIView {
        func takeScreenshot() -> UIImage {
            UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, UIScreen.main.scale)
            layer.render(in: UIGraphicsGetCurrentContext()!)
            let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return capturedImage
        }

        func takeScreenshot(afterScreenUpdates: Bool) -> UIImage {
            if !responds(to: #selector(drawHierarchy(in:afterScreenUpdates:))) {
                return self.takeScreenshot()
            }
            UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, UIScreen.main.scale)
            drawHierarchy(in: bounds, afterScreenUpdates: afterScreenUpdates)
            let snapshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return snapshot!
        }
    }
#endif

extension View {
    func takeScreenshot(frame: CGRect, afterScreenUpdates: Bool) -> Image {
        #if os(iOS)
            let hosting = UIHostingController(rootView: self)
            hosting.overrideUserInterfaceStyle = UIApplication.shared.currentUIWindow()?.overrideUserInterfaceStyle ?? .unspecified
            hosting.view.frame = frame
            let uiImage = hosting.view.takeScreenshot(afterScreenUpdates: afterScreenUpdates)
            return Image(uiImage: uiImage)
        #else
            let controller = NSHostingController(rootView: self)
            let targetSize = controller.view.intrinsicContentSize
            let contentRect = NSRect(origin: .zero, size: targetSize)

            let window = NSWindow(
                contentRect: contentRect,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            window.contentView = controller.view

            guard
                let bitmapRep = controller.view.bitmapImageRepForCachingDisplay(in: contentRect)
            else { return Image("AppIcon") }

            controller.view.cacheDisplay(in: contentRect, to: bitmapRep)

            let image = NSImage(size: bitmapRep.size)
            image.addRepresentation(bitmapRep)
            return Image(nsImage: image)
        #endif
    }
}

#if os(iOS)
    extension UIApplication {
        func currentUIWindow() -> UIWindow? {
            let connectedScenes = UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }

            let window = connectedScenes.first?
                .windows
                .first { $0.isKeyWindow }

            return window
        }
    }
#endif
