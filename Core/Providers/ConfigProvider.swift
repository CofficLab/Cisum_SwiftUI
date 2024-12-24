import AVKit
import Combine
import Foundation
import MediaPlayer
import OSLog
import SwiftUI
import MagicKit

enum StorageLocation: String, Codable {
    case icloud
    case local
    case custom
}

class ConfigProvider: NSObject, ObservableObject, AVAudioPlayerDelegate, SuperLog, SuperThread {
    static let emoji: String = "🔩"
    static let keyOfStorageLocation = "StorageLocation"
    
    @Published var storageLocation: StorageLocation?
    
    override init() {
        super.init()
        // 从 UserDefaults 加载存储位置设置
        if let savedLocation = UserDefaults.standard.string(forKey: Self.keyOfStorageLocation),
           let location = StorageLocation(rawValue: savedLocation) {
            self.storageLocation = location
        }
    }
    
    func updateStorageLocation(_ location: StorageLocation?) {
        self.storageLocation = location
        // 保存到 UserDefaults
        UserDefaults.standard.set(location?.rawValue, forKey: Self.keyOfStorageLocation)
    }
}

