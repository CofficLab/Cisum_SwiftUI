import Combine
import Foundation
import ProviderStorage

@MainActor
final class StorageSettingsViewModel: ObservableObject {
    @Published private(set) var location: StoragePluginLocation?
    @Published private(set) var isICloudAvailable = false
    @Published private(set) var isLocalStorageAvailable = false

    private weak var storage: (any StorageProviding)?

    init(storage: (any StorageProviding)?) {
        self.storage = storage
        refresh()
    }

    /// 当前存储位置解析出的根 URL；不可用时为 `nil`。
    var storageRoot: URL? {
        storage?.storageRoot
    }

    /// 解析指定存储位置对应的根 URL；不可用时返回 `nil`。
    func storageRoot(for location: StoragePluginLocation) -> URL? {
        storage?.storageRoot(for: StorageLocation(location))
    }

    /// 用户意图：设置存储位置。
    func setStorageLocation(_ location: StoragePluginLocation?) {
        storage?.setStorageLocation(location.map { StorageLocation($0) })
    }

    func handle(_ event: StoragePluginEvent) {
        switch event {
        case .providerChanged:
            refresh()
        }
    }

    private func refresh() {
        location = storage?.currentStorageLocation.map(StoragePluginLocation.init)
        isICloudAvailable = storage?.storageRoot(for: .icloud) != nil
        isLocalStorageAvailable = storage?.storageRoot(for: .local) != nil
    }
}
