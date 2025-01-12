import Combine
import Foundation
import MagicKit

import OSLog
import StoreKit
import SwiftData
import SwiftUI

class AudioProvider: ObservableObject, SuperLog, SuperThread, SuperEvent {
    private var cancellables = Set<AnyCancellable>()
    private var debounceTimer: Timer?

    static let emoji = "🌿"
    private(set) var disk: URL

    @Published private(set) var files: [MetaWrapper] = []
    @Published private(set) var isSyncing: Bool = false

    init(disk: URL) {
        self.disk = disk
        self.nc.publisher(for: .dbSyncing)
            .sink { [weak self] notification in
                self?.handleDBSyncing(notification)
            }
            .store(in: &cancellables)

        self.nc.publisher(for: .dbSynced)
            .sink { [weak self] notification in
                self?.handleDBSynced(notification)
            }
            .store(in: &cancellables)
    }
    
    /// 更新音频文件目录路径
    /// - Parameter newDisk: 新的目录路径
    func updateDisk(_ newDisk: URL) {
        os_log("\(self.t)🍋🍋🍋 updateDisk to \(newDisk.path)")

        self.cancellables.removeAll()
        self.disk = newDisk
    }
}

// MARK: Event Handler

extension AudioProvider {
    private func handleDBSyncing(_ notification: Notification) {
        if let items = notification.userInfo?["items"] as? [MetaWrapper] {
            self.setFiles(items)
            self.setSyncing(true)
        }
    }

    private func handleDBSynced(_ notification: Notification) {
        self.setSyncing(false)
    }
}

// MARK: State Updater

extension AudioProvider {
    private func setSyncing(_ syncing: Bool) {
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

    private func setFiles(_ files: [MetaWrapper]) {
        self.files = files
    }
}
