import Foundation
import SwiftData
import OSLog

/**
 记录场景数据，并通过 CloudKit 同步
 */
@Model
class SceneState {
    var scene: DiskScene.RawValue?
    
    /// 当前播放的URL
    var currentURL: URL?
    
    /// 播放进度
    var time: TimeInterval? = 0
    
    var currentTitle: String {
        currentURL?.lastPathComponent ?? "无"
    }
    
    init(scene: DiskScene, currentURL: URL? = nil, time: TimeInterval = 0) {
        self.scene = scene.rawValue
        self.currentURL = currentURL
        self.time = time
    }
}

// MARK: Descriptor

extension SceneState {
    static var descriptorAll = FetchDescriptor(predicate: #Predicate<SceneState> { _ in
        return true
    }, sortBy: [])
    
    static func descriptorOf(_ scene: DiskScene) -> FetchDescriptor<SceneState> {
        let rawValue = scene.rawValue
        
        return FetchDescriptor(predicate: #Predicate<SceneState> { s in
            s.scene == rawValue
        }, sortBy: [])
    }
}
