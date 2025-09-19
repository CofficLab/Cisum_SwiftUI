import Combine
import Foundation
import MagicCore
import OSLog
import StoreKit
import SwiftData
import SwiftUI

@MainActor
class AudioProvider: ObservableObject, SuperLog, SuperThread, SuperEvent {
    var repo: AudioRepo

    nonisolated static let emoji = "🌿"
    private(set) var disk: URL
    var verbose: Bool = false

    nonisolated init(disk: URL, db: AudioRepo) {
        self.disk = disk
        self.repo = db
    }

    func updateDisk(_ newDisk: URL) {
        if verbose { os_log("\(self.t)🍋 updateDisk to \(newDisk.path)") }
        self.disk = newDisk
    }
}

#if os(macOS)
#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 600, height: 600)
}
#endif

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif
