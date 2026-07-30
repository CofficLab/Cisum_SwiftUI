import CisumUI
import Foundation

// MARK: - Service Accessors

extension CisumKernelContainer {
    /// 音频库服务 —— 提供 AudioDB 所需的抽象音频库能力。
    public var audioLibrary: (any AudioLibraryProviding)? {
        resolveService((any AudioLibraryProviding).self)
    }

    /// 存储服务 —— 管理数据存储位置（iCloud / 本地 / 自定义）。
    public var storage: (any StorageProviding)? {
        resolveService(StorageProviding.self)
    }

    /// 播放服务 —— 控制音频/有声书播放状态。
    public var playback: (any PlaybackProviding)? {
        resolveService(PlaybackProviding.self)
    }

    /// 插件服务 —— 插件发现、注册、生命周期管理。
    public var plugin: (any PluginProviding)? {
        resolveService(PluginProviding.self)
    }

    /// 主题服务 —— 主题贡献收集、选择与同步。
    public var theme: (any ThemeProviding)? {
        resolveService(ThemeProviding.self)
    }

    /// 云同步服务 —— iCloud 状态监控。
    public var cloud: (any CloudProviding)? {
        resolveService(CloudProviding.self)
    }

    /// 应用状态服务 —— 应用级 UI 状态管理。
    public var appState: (any AppStateProviding)? {
        resolveService(AppStateProviding.self)
    }

    /// 设备数据服务 —— 设备信息访问。
    public var device: (any DeviceProviding)? {
        resolveService(DeviceProviding.self)
    }
}
