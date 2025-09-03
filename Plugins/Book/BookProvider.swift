import Combine
import Foundation
import MagicCore

import OSLog
import StoreKit
import SwiftData
import SwiftUI

class BookProvider: ObservableObject, SuperLog, SuperThread, SuperEvent {
    static let emoji = "🌿"
    let disk: URL

    init(disk: URL) {
        self.disk = disk
    }
}

#if os(macOS)
    #Preview("App - Large") {
        AppPreview()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        AppPreview()
            .frame(width: 500, height: 800)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        AppPreview()
    }
#endif
