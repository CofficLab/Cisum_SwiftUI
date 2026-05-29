// 系统工具栏会自动加样式，所以用原生 Button 最好，不要用自定义按钮组件。

import CisumUI
import MagicKit
import MagicPlayMan
import OSLog
import SwiftUI

public struct OpenCurrentButtonView: View, SuperLog {
    public nonisolated static let emoji = "😜"
    public static let verbose = false
    public static var order: Int { 20 }

    @EnvironmentObject var man: MagicPlayMan
    @State private var url: URL?

    public init() {}

    public var body: some View {
        if Self.verbose {
            os_log("\(self.t)开始渲染")
        }
        return Group {
            if let url {
                Button {
                    url.openInFinder()
                } label: {
                    Image(systemName: .cisumIconShowInFinder)
                }
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
}
