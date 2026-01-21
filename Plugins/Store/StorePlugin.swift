import Foundation
import MagicKit
import OSLog
import SwiftUI

actor StorePlugin: SuperPlugin, SuperLog {
    static let emoji = "🛒"
    static let verbose = false
    static var shouldRegister: Bool { true }

    /// 注册顺序设为 80，在其他插件之后执行
    static var order: Int { 80 }

    let title = "商店"
    let description = "应用内购买和订阅"
    let iconName = "cart"
    

    @MainActor
    func addSettingView() -> AnyView? {
        AnyView(StoreSettingEntry())
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
