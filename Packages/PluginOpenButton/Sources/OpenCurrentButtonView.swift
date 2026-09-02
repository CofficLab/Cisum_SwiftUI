// 系统工具栏会自动加样式，所以用原生 Button 最好，不要用自定义按钮组件。

import CisumUI
import MagicPlayMan
import OSLog
import SwiftUI

public struct OpenCurrentButtonView: View, SuperLog {
    public nonisolated static let emoji = "😜"
    public static let verbose = false
    nonisolated static let accessibilityTitle = String(localized: "Show in Finder", bundle: .module)
    public static var order: Int { 20 }

    @EnvironmentObject var man: MagicPlayMan
    @State private var url: URL?

    public init() {}

    public var body: some View {
        if Self.verbose {
            os_log("\(self.t)开始渲染")
        }
        return Group {
            if let url, Self.shouldShowOpenButton(for: url) {
                Button(Self.accessibilityTitle, systemImage: .cisumIconShowInFinder) {
                    url.openInFinder()
                }
                .accessibilityLabel(Text(Self.accessibilityTitle))
                .accessibilityRepresentation {
                    Button(Self.accessibilityTitle) {}
                }
                .help(Text(Self.accessibilityTitle))
                .id(url.absoluteString)
            }
        }
        .onPlayManAssetChanged {
            self.url = $0
        }
        .onAppear {
            if let url = man.asset {
                self.url = url
            }
        }
    }

    nonisolated static func shouldShowOpenButton(
        for url: URL,
        fileExists: (String) -> Bool = FileManager.default.fileExists(atPath:)
    ) -> Bool {
        url.isFileURL && fileExists(url.path)
    }
}
