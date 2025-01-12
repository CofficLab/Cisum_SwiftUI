import Foundation
import MagicKit
import OSLog
import SwiftData
import SwiftUI

actor MessagePlugin: SuperPlugin, SuperLog {
    static let emoji = "🎧"

    let label = "Message"
    let hasPoster = true
    let description = "Message 插件"
    let iconName = "message"
    let isGroup = false

    @MainActor func addToolBarButtons() -> [(id: String, view: AnyView)] {
        return [
            ("log", AnyView(MagicLogger
                    .logButton()
                    .magicSize(.small)
                    .magicShapeVisibility(.onHover)
                    //.onlyDebug()
            )
            ),
        ]
    }
}
