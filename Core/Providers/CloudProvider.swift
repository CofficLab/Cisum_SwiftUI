import AVKit
import Combine
import Foundation
import MagicKit
import MagicUI
import MediaPlayer
import OSLog
import SwiftUI

@MainActor
class CloudProvider: NSObject, ObservableObject, @preconcurrency SuperLog, SuperThread, SuperEvent {
    static let emoji: String = "☃️"
    
    @Published private(set) var isSignedIn: Bool?
    @Published private(set) var accountStatus: String = ""
    
    var isSignedInDescription: String {
        if let isSignedIn = isSignedIn {
            return isSignedIn ? "已登录" : "未登录"
        }
        
        return "未知"
    }
    
    init(verbose: Bool = false) {
        super.init()
        
        if verbose {
            os_log("\(Self.i)")
        }
        
        updateAccountStatus()
        
        // 监听 iCloud 状态变化
        nc.addObserver(
            self,
            selector: #selector(handleAccountChange),
            name: NSNotification.Name.CKAccountChanged,
            object: nil
        )
    }
    
    private func updateAccountStatus(verbose: Bool = false) {
        Task {
            let status = FileManager.default.ubiquityIdentityToken != nil
            await MainActor.run {
                self.isSignedIn = status
                self.accountStatus = status ? "已登录" : "未登录"
                
                if verbose {
                    os_log("\(self.t)🍋🍋🍋 iCloud 状态更新: isSignedIn=\(status), accountStatus=\(self.accountStatus)")
                }
            }
        }
    }
    
    @objc private func handleAccountChange(verbose: Bool = false) {
        if verbose {
            os_log("\(self.t)🍋🍋🍋 检测到 iCloud 账户变化")
        }
        
        updateAccountStatus(verbose: verbose)
    }
}
