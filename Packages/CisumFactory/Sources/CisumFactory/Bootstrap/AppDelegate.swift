#if os(macOS)
    import AppKit
    import SwiftUI

    /// macOS 应用代理（对齐 Lumi 的 `MacAgent`，由 App target 通过
    /// `@NSApplicationDelegateAdaptor` 采用）。
    ///
    /// 仅保留必要职责：禁用状态恢复，以及在 Dock 点击 / `open -a` 重新激活主窗口。
    @MainActor
    public final class AppDelegate: NSObject, NSApplicationDelegate {
        public override init() {
            super.init()
        }

        public func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
            false
        }

        public func application(_ app: NSApplication, shouldSaveSecureApplicationState coder: NSCoder) -> Bool {
            false
        }

        public func application(_ app: NSApplication, shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
            false
        }

        public func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
            if !flag, AppWindowController.showExistingMainWindow(in: sender) {
                return false
            }
            return true
        }
    }

    /// 主窗口控制器：重新激活已存在的主窗口。
    @MainActor
    enum AppWindowController {
        static let mainWindowID = AppBootstrap.mainWindowID

        @discardableResult
        static func showExistingMainWindow(in app: NSApplication = .shared) -> Bool {
            guard let window = app.windows.first(where: isMainAppWindow) else { return false }

            if window.isMiniaturized {
                window.deminiaturize(nil)
            }
            app.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            return true
        }

        private static func isMainAppWindow(_ window: NSWindow) -> Bool {
            (window.isVisible || window.isMiniaturized)
                && window.canBecomeMain
                && window.level == .normal
        }
    }
#endif
