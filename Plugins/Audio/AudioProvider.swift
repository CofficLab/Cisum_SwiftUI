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
    var verbose: Bool = true

    @Published private(set) var files: [URL] = []

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
                    if verbose { os_log("\(self.t)从 \(self.files.count) 个变为 \(items.count) 个") }
                    self.files = items
                }
            }
            .store(in: &cancellables)
    }

    func updateDisk(_ newDisk: URL) {
        if verbose { os_log("\(self.t)🍋🍋🍋 updateDisk to \(newDisk.path)") }
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
            }
        }
    }
}

// MARK: State Updater

extension AudioProvider {
    private func setFiles(_ files: [URL]) {
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
        .frame(width: 600, height: 600)
}
#endif

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif
