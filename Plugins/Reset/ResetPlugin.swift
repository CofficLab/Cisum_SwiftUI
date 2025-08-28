import Foundation
import MagicCore
import OSLog
import SwiftUI

actor ResetPlugin: SuperPlugin, SuperLog {
    static let emoji = "⚙️"

    let label = "Reset"
    let hasPoster = false
    let description: String = "恢复默认配置"
    let iconName: String = .iconReset
    nonisolated(unsafe) var enabled: Bool = false
    
    @MainActor
    func addSettingView() -> AnyView? {
        guard enabled else { return nil }
        return AnyView(ResetSetting())
    }
}

#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 500, height: 800)
}

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif

