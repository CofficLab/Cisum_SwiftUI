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
                AppIconButton(systemImage: .cisumIconShowInFinder, size: .regular) {
                    url.openInFinder()
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
