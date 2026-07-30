import Foundation

/// CisumKernel 错误类型。
public enum CisumKernelError: Error, LocalizedError {
    /// 插件 ID 重复。
    case pluginAlreadyRegistered(id: String)

    /// 未找到插件。
    case pluginNotFound(id: String)

    /// 缺少必需服务。
    ///
    /// - Parameter services: 缺失的服务名称列表。
    case missingRequiredServices([String])

    /// 服务不可用。
    ///
    /// - Parameter service: 服务名称。
    case serviceNotAvailable(service: String)

    /// 场景未找到。
    ///
    /// - Parameter sceneName: 场景名称。
    case sceneNotFound(sceneName: String)

    /// 插件 ID 为空。
    case pluginIDIsEmpty

    /// 插件 ID 重复。
    ///
    /// - Parameters:
    ///   - pluginID: 重复的插件 ID。
    ///   - existing: 已存在的插件 ID 集合。
    case duplicatePluginID(pluginID: String, existing: [String])

    /// 播放器不处于可播放状态。
    case playbackNotReady

    /// 主题不合法或未找到。
    case invalidTheme(themeID: String)

    /// 存储路径无效。
    case invalidStoragePath(path: String)

    // MARK: - LocalizedError

    public var errorDescription: String? {
        switch self {
        case .pluginAlreadyRegistered(let id):
            "Plugin '\(id)' is already registered"
        case .pluginNotFound(let id):
            "Plugin '\(id)' not found"
        case .missingRequiredServices(let services):
            "Missing required services: \(services.joined(separator: ", "))"
        case .serviceNotAvailable(let service):
            "\(service) service is not available"
        case .sceneNotFound(let sceneName):
            "Scene '\(sceneName)' not found"
        case .pluginIDIsEmpty:
            "Plugin has an empty ID"
        case .duplicatePluginID(let pluginID, _):
            "Duplicate plugin ID: \(pluginID)"
        case .playbackNotReady:
            "Playback manager is not ready — no playable asset loaded"
        case .invalidTheme(let themeID):
            "Invalid or unknown theme: \(themeID)"
        case .invalidStoragePath(let path):
            "Invalid storage path: \(path)"
        }
    }
}
