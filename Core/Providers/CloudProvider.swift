import AVKit
import Combine
import Foundation
import MagicKit
import MediaPlayer
import OSLog
import SwiftUI

@MainActor
class CloudProvider: NSObject, ObservableObject, @preconcurrency SuperLog, SuperThread, SuperEvent {
    static let emoji: String = "☃️"
    
    @Published private(set) var isSignedIn: Bool = false
    @Published private(set) var accountStatus: String = ""
    
    override init() {
        super.init()
        os_log("\(self.i)")
        updateAccountStatus()
        
        // 监听 iCloud 状态变化
        nc.addObserver(
            self,
            selector: #selector(handleAccountChange),
            name: NSNotification.Name.CKAccountChanged,
            object: nil
        )
    }
    
    private func updateAccountStatus() {
        Task {
            let status = FileManager.default.ubiquityIdentityToken != nil
            await MainActor.run {
                self.isSignedIn = status
                self.accountStatus = status ? "已登录" : "未登录"
                
                os_log("\(self.t)🍋🍋🍋 iCloud 状态更新: isSignedIn=\(status), accountStatus=\(self.accountStatus)")
            }
        }
    }
    
    @objc private func handleAccountChange() {
        os_log("\(self.t)检测到 iCloud 账户变化")
        updateAccountStatus()
    }
}
