import Combine
import Foundation
import MagicCore
import OSLog
import StoreKit
import SwiftData
import SwiftUI

@MainActor
class AudioProvider: ObservableObject, SuperLog, SuperThread, SuperEvent {
    private var cancellables = Set<AnyCancellable>()
    private var debounceTimer: Timer?

    nonisolated static let emoji = "🌿"
    private(set) var disk: URL

    @Published private(set) var files: [URL] = []
    @Published private(set) var isSyncing: Bool = false
    @Published private(set) var downloadProgress: [String: Double] = [:]

    nonisolated init(disk: URL) {
        self.disk = disk
        
        Task { @MainActor in
            self.setupNotifications()
        }
    }
    
    private func setupNotifications() {
        self.nc.publisher(for: .dbSyncing)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                guard let self = self else { return }
                if let items = notification.userInfo?["items"] as? [URL] {
                    self.files = items
                    self.setSyncing(true)
                }
            }
            .store(in: &cancellables)

        self.nc.publisher(for: .dbSynced)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.setSyncing(false)
            }
            .store(in: &cancellables)

        self.nc.publisher(for: .audioDownloadProgress)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                guard let self = self,
                      let url = notification.userInfo?["url"] as? URL,
                      let progress = notification.userInfo?["progress"] as? Double
                else { return }
                
                if progress >= 1.0 {
                    self.downloadProgress.removeValue(forKey: url.path)
                } else {
                    self.downloadProgress[url.path] = progress
                }
            }
            .store(in: &cancellables)
    }

    func updateDisk(_ newDisk: URL) {
        os_log("\(self.t)🍋🍋🍋 updateDisk to \(newDisk.path)")
        self.cancellables.removeAll()
        self.disk = newDisk
        self.setupNotifications()
    }
}

// MARK: Event Handler

extension AudioProvider {
    private func handleDBSyncing(_ notification: Notification) {
        if let items = notification.userInfo?["items"] as? [URL] {
            Task {
                self.setFiles(items)
                self.setSyncing(true)
            }
        }
    }

    private func handleDBSynced(_ notification: Notification) {
        Task {
            self.setSyncing(false)
        }
    }

    private func handleDownloadProgress(_ notification: Notification) {
        guard let url = notification.userInfo?["url"] as? URL,
              let progress = notification.userInfo?["progress"] as? Double else { return }

        let progressUpdate = (path: url.path, value: progress)

        Task { @MainActor in
            if progressUpdate.value >= 1.0 {
                self.downloadProgress.removeValue(forKey: progressUpdate.path)
            } else {
                self.downloadProgress[progressUpdate.path] = progressUpdate.value
            }
        }
    }
}

// MARK: State Updater

extension AudioProvider {
    private func setSyncing(_ syncing: Bool) {
        withAnimation {
            self.isSyncing = syncing
        }
    }

    private func setFiles(_ files: [URL]) {
        self.files = files
    }
}

#Preview("Big Screen") {
    RootView {
        ContentView()
    }
    .frame(width: 1200)
    .frame(height: 1200)
}

