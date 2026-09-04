import CisumUIComponents
import Foundation
import ProviderAppState
import ProviderAudioLibrary
import ProviderCloud
import ProviderDevice
import ProviderPlayback
import ProviderStorage
import ProviderTheme

// MARK: - Service Registration

extension CisumKernelContainer {
    /// 注册音频库服务。
    public func registerAudioLibrary(_ library: any AudioLibraryProviding) {
        registerProvider(AudioLibraryProviding.self, library)
    }

    /// 注册存储服务。
    public func registerStorage(_ storage: any StorageProviding) {
        registerProvider(StorageProviding.self, storage)
    }

    /// 注册播放服务。
    public func registerPlayback(_ playback: any PlaybackProviding) {
        registerProvider(PlaybackProviding.self, playback)
    }

    /// 注册插件管理服务。
    public func registerPluginService(_ plugin: any PluginProviding) {
        registerProvider(PluginProviding.self, plugin)
    }

    /// 注册主题服务。
    public func registerThemeService(_ theme: any ThemeProviding) {
        registerProvider(ThemeProviding.self, theme)
    }

    /// 注册云同步服务。
    public func registerCloudService(_ cloud: any CloudProviding) {
        registerProvider(CloudProviding.self, cloud)
    }

    /// 注册应用状态服务。
    public func registerAppStateService(_ appState: any AppStateProviding) {
        registerProvider(AppStateProviding.self, appState)
    }

    /// 注册设备数据服务。
    public func registerDeviceService(_ device: any DeviceProviding) {
        registerProvider(DeviceProviding.self, device)
    }
}
