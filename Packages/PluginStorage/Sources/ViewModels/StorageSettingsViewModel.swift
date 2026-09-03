import Combine
import Foundation
import ProviderStorage

@MainActor
final class StorageSettingsViewModel: ObservableObject {
    @Published private(set) var location: StoragePluginLocation?
    @Published private(set) var isICloudAvailable = false
    @Published private(set) var isLocalStorageAvailable = false

    private weak var storage: (any StorageProviding)?
    private var observer: StorageProvidingObserver?

    init(storage: (any StorageProviding)?) {
        attach(to: storage)
    }

    func attach(to storage: (any StorageProviding)?) {
        observer?.cancel()
        observer = nil
        self.storage = storage
        refresh()

        guard let storage else { return }
        observer = StorageProvidingObserver(provider: storage, viewModel: self)
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
