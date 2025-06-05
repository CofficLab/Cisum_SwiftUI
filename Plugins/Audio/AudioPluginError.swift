import Foundation
import SwiftUI

enum AudioPluginError: Error, LocalizedError {
    case NoNextAsset
    case NoPrevAsset
    case NoDisk

    var errorDescription: String? {
        switch self {
        case .NoNextAsset:
            return "No next asset"
        case .NoPrevAsset:
            return "No prev asset"
        case .NoDisk:
            return "No disk"
        }
    }
}

/// 音频记录数据库错误类型
enum AudioRecordDBError: Error {
    /// 切换喜欢状态时发生错误
    case ToggleLikeError(Error)
    /// 未找到指定 URL 的音频
    case AudioNotFound(URL)
}

#Preview("Small Screen") {
    RootView {
        UserDefaultsDebugView(defaultSearchText: "AudioPlugin")
    }
    .frame(width: 500)
    .frame(height: 600)
}

#Preview("Big Screen") {
    RootView {
        UserDefaultsDebugView()
    }
    .frame(width: 800)
    .frame(height: 1200)
}
