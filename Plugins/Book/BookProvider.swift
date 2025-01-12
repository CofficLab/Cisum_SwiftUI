import Combine
import Foundation
import MagicKit

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
    @Published var isSyncing: Bool = true

    init(disk: URL) {
        self.disk = disk
        self.nc.publisher(for: .bookDBSyncing)
            .sink { [weak self] notification in
                self?.handleDBSyncing(notification)
            }
            .store(in: &cancellables)

        self.nc.publisher(for: .bookDBSynced)
            .sink { [weak self] notification in
                self?.handleDBSynced(notification)
            }
            .store(in: &cancellables)
    }

    private func handleDBSyncing(_ notification: Notification) {
        if let items = notification.userInfo?["items"] as? [URL] {
            self.files = items
            self.setSyncing(true)
        }
    }

    private func handleDBSynced(_ notification: Notification) {
        self.setSyncing(false)
    }
}

// MARK: Set

extension BookProvider {
    func setFiles(files: [URL]) {
        self.files = files
    }

    func setSyncing(_ syncing: Bool) {
        if syncing {
            debounceTimer?.invalidate()
            withAnimation {
                self.isSyncing = true
            }
        } else {
            debounceTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
                Task { @MainActor in
                    withAnimation {
                        self?.isSyncing = false
                    }
                }
            }
        }
    }
}
