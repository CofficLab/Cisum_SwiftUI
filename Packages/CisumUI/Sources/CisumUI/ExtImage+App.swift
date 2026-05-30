import SwiftUI

/// Image 的扩展，提供真实应用图标
/// 优先返回真实应用图标（如果已安装），否则返回系统图标
public extension Image {
    // MARK: - Developer Tools

    /// Xcode 应用图标（优先使用真实图标）
    static var xcodeApp: Image {
        appIcon(for: .xcode)
    }

    /// VS Code 应用图标（优先使用真实图标）
    static var vscodeApp: Image {
        appIcon(for: .vscode)
    }

    /// Cursor 应用图标（优先使用真实图标）
    static var cursorApp: Image {
        appIcon(for: .cursor)
    }

    /// Trae 应用图标（优先使用真实图标）
    static var traeApp: Image {
        appIcon(for: .trae)
    }

    /// Antigravity 应用图标（优先使用真实图标）
    static var antigravityApp: Image {
        appIcon(for: .antigravity)
    }

    /// GitHub Desktop 应用图标（优先使用真实图标）
    static var githubDesktopApp: Image {
        appIcon(for: .githubDesktop)
    }

    /// Kiro 应用图标（优先使用真实图标）
    static var kiroApp: Image {
        appIcon(for: .kiro)
    }

    // MARK: - Browsers

    /// Safari 应用图标（优先使用真实图标）
    static var safariApp: Image {
        appIcon(for: .safari)
    }

    /// Chrome 应用图标（优先使用真实图标）
    static var chromeApp: Image {
        appIcon(for: .chrome)
    }

    /// Firefox 应用图标（优先使用真实图标）
    static var firefoxApp: Image {
        appIcon(for: .firefox)
    }

    /// Edge 应用图标（优先使用真实图标）
    static var edgeApp: Image {
        appIcon(for: .edge)
    }

    /// Arc 应用图标（优先使用真实图标）
    static var arcApp: Image {
        appIcon(for: .arc)
    }

    // MARK: - System Apps

    /// Finder 应用图标（优先使用真实图标）
    static var finderApp: Image {
        appIcon(for: .finder)
    }

    /// Terminal 真实应用图标（优先使用真实图标）
    static var terminalRealApp: Image {
        appIcon(for: .terminal)
    }

    /// Preview 应用图标（优先使用真实图标）
    static var previewRealApp: Image {
        appIcon(for: .preview)
    }

    /// TextEdit 应用图标（优先使用真实图标）
    static var textEditRealApp: Image {
        appIcon(for: .textEdit)
    }

    // MARK: - Helper Methods

    /// 根据应用类型获取应用图标
    /// - Parameter appType: 应用类型
    /// - Returns: 应用图标（真实图标如果已安装，否则使用系统图标）
    private static func appIcon(for appType: OpenAppType) -> Image {
        #if os(macOS)
        // 尝试获取真实应用图标
        if let nsImage = appType.realIcon(useRealIcon: true) as? NSImage {
            return Image(nsImage: nsImage)
        }
        #endif

        // 回退到系统图标
        return Image(systemName: appType.icon)
    }
}

#if DEBUG
// MARK: - Previews

#Preview("App Icon Extensions") {
    VStack(spacing: 30) {
        Text("Image 扩展 - 真实应用图标")
            .font(.title)
            .padding()

        Text("使用 Image.xcodeApp 等快捷方式获取应用图标")
            .font(.caption)
            .foregroundColor(.secondary)

        LazyVGrid(columns: [
            GridItem(.adaptive(minimum: 100))
        ], spacing: 20) {
            AppIconPreviewRow(name: "Xcode", icon: .xcodeApp)
            AppIconPreviewRow(name: "VS Code", icon: .vscodeApp)
            AppIconPreviewRow(name: "Cursor", icon: .cursorApp)
            AppIconPreviewRow(name: "Safari", icon: .safariApp)
            AppIconPreviewRow(name: "Chrome", icon: .chromeApp)
            AppIconPreviewRow(name: "Firefox", icon: .firefoxApp)
            AppIconPreviewRow(name: "Finder", icon: .finderApp)
            AppIconPreviewRow(name: "Terminal", icon: .terminalRealApp)
            AppIconPreviewRow(name: "Preview", icon: .previewRealApp)
            AppIconPreviewRow(name: "TextEdit", icon: .textEditRealApp)
        }
        .padding()

        Divider()
            .padding()

        VStack(spacing: 12) {
            Text("使用示例")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                CodeExample(text: "Image.xcodeApp")
                CodeExample(text: "Image.vscodeApp")
                CodeExample(text: "Image.safariApp")
                CodeExample(text: "Image.chromeApp")
                CodeExample(text: "Image.finderApp")
            }
        }
        .padding()
    }
    .inScrollView()
    .frame(width: 500, height: 800)
}

struct AppIconPreviewRow: View {
    let name: String
    let icon: Image

    var body: some View {
        VStack(spacing: 8) {
            icon.resizable()
                .frame(width: 48, height: 48)

            Text(name)
                .font(.caption)
        }
    }
}

struct CodeExample: View {
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(text)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.primary)
            Spacer()
        }
    }
}
#endif
