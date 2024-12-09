import Foundation
import MagicKit
import OSLog
import StoreKit
import SwiftData
import SwiftUI
import Combine

class AudioProvider: ObservableObject, SuperLog, SuperThread, SuperEvent {
    private var cancellables = Set<AnyCancellable>()
    let emoji = "🌿"

    @Published var files: [DiskFile] = []
    @Published var isSyncing: Bool = true
    
    private var debounceTimer: Timer?

    init() {
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
    
    private func handleDBSyncing(_ notification: Notification) {
        if let group = notification.userInfo?["group"] as? DiskFileGroup {
            self.files = group.files
            
            if group.isFullLoad {
                os_log("\(self.t)handleDBSyncing: isFullLoad")
                self.setSyncing(false)
            } else {
                os_log("\(self.t)handleDBSyncing: isNotFullLoad")
                self.setSyncing(true)
            }
        }
    }

    private func handleDBSynced(_ notification: Notification) {
        self.setSyncing(false)
    }

    func setSyncing(_ syncing: Bool) {
        if syncing {
            debounceTimer?.invalidate()
            withAnimation {
                self.isSyncing = true
            }
        } else {
            debounceTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                withAnimation {
                    self?.isSyncing = false
                }
            }
        }
    }
}
