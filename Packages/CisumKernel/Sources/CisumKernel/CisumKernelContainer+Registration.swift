import CisumUI
import Foundation

// MARK: - Service Registration

extension CisumKernelContainer {
    /// 注册音频库服务。
    public func registerAudioLibrary(_ library: any AudioLibraryProviding) {
        registerService((any AudioLibraryProviding).self, library)
    }

    /// 注册存储服务。
    public func registerStorage(_ storage: any StorageProviding) {
        registerService(StorageProviding.self, storage)
    }

    /// 注册播放服务。
    public func registerPlayback(_ playback: any PlaybackProviding) {
        registerService(PlaybackProviding.self, playback)
    }

    /// 注册插件管理服务。
    public func registerPluginService(_ plugin: any PluginProviding) {
        registerService(PluginProviding.self, plugin)
    }

    /// 注册主题服务。
    public func registerThemeService(_ theme: any ThemeProviding) {
        registerService(ThemeProviding.self, theme)
    }

    /// 注册云同步服务。
    public func registerCloudService(_ cloud: any CloudProviding) {
        registerService(CloudProviding.self, cloud)
    }

    /// 注册应用状态服务。
    public func registerAppStateService(_ appState: any AppStateProviding) {
        registerService(AppStateProviding.self, appState)
    }

    /// 注册设备数据服务。
    public func registerDeviceService(_ device: any DeviceProviding) {
        registerService(DeviceProviding.self, device)
    }
}
