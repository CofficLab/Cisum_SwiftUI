import Foundation
import MagicKit
import OSLog
import SwiftUI

actor ResetPlugin: SuperPlugin, SuperLog {
    static let emoji = "🔄"
    static let verbose = false
    static var shouldRegister: Bool { true }

    /// 注册顺序设为 95，最后执行
    static var order: Int { 95 }

    let title = "重置"
    let description = "恢复默认配置"
    let iconName = "arrow.counterclockwise"
    

    @MainActor
    func addSettingView() -> AnyView? {
        return AnyView(ResetSetting())
    }
}



#Preview("ResetConfirmContent") {
    RootView {
        ResetConfirmContent(onCancel: {}, onConfirm: {})
            .padding()
            .frame(width: 400)
    }
}

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

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
            .inRootView()
    }
#endif
