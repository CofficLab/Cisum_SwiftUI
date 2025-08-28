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
    var db: AudioRepo

    nonisolated static let emoji = "🌿"
    private(set) var disk: URL
    var verbose: Bool = true

    // 移除 @Published files，因为现在从 db 获取
    private(set) var files: [URL] = []

    nonisolated init(disk: URL, db: AudioRepo) {
        self.disk = disk
        self.db = db
        
        Task { @MainActor in
            self.setupStateObservation()
        }
    }
    
    private func setupStateObservation() {
        // 观察 db 的状态变化
        db.$files
            .receive(on: RunLoop.main)
            .sink { [weak self] files in
                guard let self = self else { return }
                if verbose { os_log("\(self.t)从 \(self.files.count) 个变为 \(files.count) 个") }
                self.files = files
            }
            .store(in: &cancellables)
    }

    func updateDisk(_ newDisk: URL) {
        if verbose { os_log("\(self.t)🍋🍋🍋 updateDisk to \(newDisk.path)") }
        self.cancellables.removeAll()
        self.disk = newDisk
        self.setupStateObservation()
    }
}

// MARK: - State Management

extension AudioProvider {
    /// 获取当前同步状态
    var syncStatus: SyncStatus {
        db.syncStatus
    }
    
    /// 获取下载进度
    var downloadProgress: [URL: Double] {
        db.downloadProgress
    }
    
    /// 检查是否正在同步
    var isSyncing: Bool {
        db.isSyncing
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
