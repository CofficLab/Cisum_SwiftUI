import Foundation
import SwiftUI

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

public extension URL {
    /// 创建打开按钮
    /// - Parameters:
    ///   - appType: 应用程序类型，默认为 .auto（智能选择）
    ///   - useRealIcon: 是否使用真实应用图标（仅macOS），默认为false使用系统图标
    /// - Returns: 打开按钮视图
    func makeOpenButton(_ appType: OpenAppType = .auto, useRealIcon: Bool = false) -> some View {
        Group {
            if useRealIcon {
                // 使用真实应用图标
                RealIconButtonView(appType: appType, url: self)
            } else {
                // 使用系统图标（SF Symbol）
                Image(systemName: appType.icon(for: self))
            }
        }
        .inButtonWithAction({
            #if os(macOS)
                openIn(appType)
            #else
                if appType == .auto {
                    open()
                } else {
                    open() // iOS上所有类型都使用默认打开方式
                }
            #endif
        })
    }

    /// 打开URL：如果是网络链接则在浏览器打开，如果是本地文件则在访达中显示
    func open() {
        if isNetworkURL {
            openInBrowser()
        } else {
            openInFinder()
        }
    }

    /// 在浏览器中打开URL
    func openInBrowser() {
        #if os(iOS)
            UIApplication.shared.open(self)
        #elseif os(macOS)
            NSWorkspace.shared.open(self)
        #endif
    }

    /// 在访达中显示文件或文件夹
    func openInFinder() {
        #if os(macOS)
            showInFinder()
        #else
            openFolder()
        #endif
    }

    #if os(macOS)
        /// 在访达中显示并选中文件
        func showInFinder() {
            NSWorkspace.shared.activateFileViewerSelecting([self])
        }

        /// 在指定的应用程序中打开
        /// - Parameter appType: 应用程序类型
        func openIn(_ appType: OpenAppType) {
            if appType == .auto {
                open()
                return
            }

            if appType == .browser {
                openInBrowser()
                return
            }

            if appType == .finder {
                openInFinder()
                return
            }

            guard let bundleId = appType.bundleId else { return }

            let configuration = NSWorkspace.OpenConfiguration()
            configuration.activates = true

            let bundleURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId)
            guard let bundleURL = bundleURL else {
                print("Failed to find application with bundle ID: \(bundleId)")
                return
            }

            NSWorkspace.shared.open(
                [self],
                withApplicationAt: bundleURL,
                configuration: configuration
            )
        }

        // MARK: - Convenience Methods

        /// 在 Xcode 中打开
        func openInXcode() {
            openIn(.xcode)
        }

        /// 在 VS Code 中打开
        func openInVSCode() {
            openIn(.vscode)
        }

        /// 在 Cursor 中打开
        func openInCursor() {
            openIn(.cursor)
        }

        /// 在 Trae 中打开
        func openInTrae() {
            openIn(.trae)
        }

        /// 在 Antigravity 中打开
        func openInAntigravity() {
            openIn(.antigravity)
        }

        /// 在 Safari 中打开
        func openInSafari() {
            openIn(.safari)
        }

        /// 在 Chrome 中打开
        func openInChrome() {
            openIn(.chrome)
        }

        /// 在 Firefox 中打开
        func openInFirefox() {
            openIn(.firefox)
        }

        /// 在 Edge 中打开
        func openInEdge() {
            openIn(.edge)
        }

        /// 在 Arc 中打开
        func openInArc() {
            openIn(.arc)
        }

        /// 在终端中打开
        func openInTerminal() {
            openIn(.terminal)
        }

        /// 在预览中打开
        func openInPreview() {
            openIn(.preview)
        }

        /// 在文本编辑器中打开
        func openInTextEdit() {
            openIn(.textEdit)
        }

        /// 在 GitHub Desktop 中打开
        func openInGitHubDesktop() {
            openIn(.githubDesktop)
        }

        /// 在 Kiro 中打开
        func openInKiro() {
            openIn(.kiro)
        }
    #endif

    /// 打开包含该文件的文件夹
    func openFolder() {
        let folderURL = self.hasDirectoryPath ? self : self.deletingLastPathComponent()
        #if os(iOS)
            UIApplication.shared.open(folderURL)
        #elseif os(macOS)
            NSWorkspace.shared.open(folderURL)
        #endif
    }
}

#if macOS
    #Preview("Open Buttons") {
        OpenPreivewView()
            .frame(height: 800)
            .frame(width: 600)
    }
#endif
