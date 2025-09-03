import Combine
import Foundation
import MagicCore

import OSLog
import StoreKit
import SwiftData
import SwiftUI

class BookProvider: ObservableObject, SuperLog, SuperThread, SuperEvent {
    private var cancellables = Set<AnyCancellable>()
    private var debounceTimer: Timer?

    static let emoji = "🌿"
    let disk: URL

    @Published var files: [URL] = []

    init(disk: URL) {
        self.disk = disk
        self.nc.publisher(for: .bookDBSyncing)
            .sink { [weak self] notification in
                self?.handleDBSyncing(notification)
            }
            .store(in: &cancellables)
    }

    private func handleDBSyncing(_ notification: Notification) {
        if let items = notification.userInfo?["items"] as? [URL] {
            self.files = items
        }
    }
}

// MARK: Set

extension BookProvider {
    func setFiles(files: [URL]) {
        self.files = files
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
