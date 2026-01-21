import Foundation
import MagicKit
import OSLog
import SwiftUI

actor VersionPlugin: SuperPlugin, SuperLog {
    static let emoji = "📱"
    static let verbose = false

    /// 注册顺序设为 90，在其他插件之后执行
    static var order: Int { 90 }

    let title = "版本"
    let description = "版本信息"
    let iconName = "info.circle"
    

    @MainActor
    func addSettingView() -> AnyView? {
        AnyView(MagicSettingSection {
            MagicSettingRow(title: "版本", description: "APP 的版本", icon: "info.circle", content: {
                Text(MagicApp.getVersion())
                    .font(.footnote)
            })
        })
    }
}

#if os(macOS)
    #Preview("App - Large") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        ContentView()
            .inRootView()
            .frame(width: 500, height: 800)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
            .inRootView()
    }
#endif
