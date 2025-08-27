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
                    if verbose { os_log("\(self.t)从 \(self.files.count) 个变为 \(items.count) 个") }
                    self.files = items
                }
            }
            .store(in: &cancellables)



//        self.nc.publisher(for: .audioDownloadProgress)
//            .receive(on: RunLoop.main)
//            .sink { [weak self] notification in
//                guard let self = self,
//                      let url = notification.userInfo?["url"] as? URL,
//                      let progress = notification.userInfo?["progress"] as? Double
//                else { return }
//                
//                let timestamp = Date().timeIntervalSince1970
//                if progress >= 1.0 {
//                    if verbose { os_log("🚨 [⬇️\(String(format: "%.3f", timestamp))] AudioProvider.downloadProgress 移除完成项：\(url.lastPathComponent)") }
//                    self.downloadProgress.removeValue(forKey: url.path)
//                } else {
//                    if verbose { os_log("🚨 [⬇️\(String(format: "%.3f", timestamp))] AudioProvider.downloadProgress 更新：\(url.lastPathComponent) = \(String(format: "%.2f", progress * 100))%") }
//                    self.downloadProgress[url.path] = progress
//                }
//            }
//            .store(in: &cancellables)
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


    private func setFiles(_ files: [URL]) {
        let timestamp = Date().timeIntervalSince1970
        if verbose { os_log("\(self.t)文件列表变更：从 \(self.files.count) 个变为 \(files.count) 个") }
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
