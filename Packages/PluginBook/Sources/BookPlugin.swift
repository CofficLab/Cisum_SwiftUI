import KernelCore
import ProviderDocsView
import CisumUIComponents
import Foundation
import ProviderStorage
import SwiftUI

public actor BookPlugin: SuperPlugin {
    public static let shared = BookPlugin()
    public static let metadata = PluginMetadata(
        displayName: BookPluginInfo.title,
        description: BookPluginInfo.description,
        iconName: BookPluginInfo.iconName,
        order: 1,
        category: .library,
    )

    nonisolated(unsafe) private var rootViewModel: BookRootViewModel?
    nonisolated(unsafe) private var rootObserver: BookStorageObserver?

    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { BookPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { BookPluginManualView() })
        }
    }

    public static let keyOfCurrentBookURL = BookPluginInfo.keyOfCurrentBookURL
    public static let keyOfCurrentBookTime = BookPluginInfo.keyOfCurrentBookTime
    public static let dirName = BookPluginInfo.dirName
    public static let supportedExtensions = BookPluginInfo.supportedExtensions

    /// OnReady 阶段（Storage 服务已注册）将 `BookPluginHost` 桥接到内核
    /// `StorageProviding`，并安装根 ViewModel + Observer。
    @MainActor
    public func onReady(kernel: CisumKernel) async throws {
        guard let storage = kernel.storage else { return }
        BookPluginHost.configure(
            dbRoot: { storage.databaseRoot },
            storageRoot: { storage.storageRoot },
            storageLocationDidChangeNotifications: [.cisumStorageLocationDidChange, .cisumStorageLocationDidReset]
        )
        installRootState(storage: storage)
    }

    @MainActor
    public func onEnable(kernel: CisumKernel) async throws {
        if let storage = kernel.storage {
            installRootState(storage: storage)
        }
    }

    @MainActor
    public func onDisable(kernel: CisumKernel) async throws {
        teardownRootState()
    }

    @MainActor
    public func onShutdown(kernel: CisumKernel) async throws {
        teardownRootState()
    }

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        let viewModel = resolveRootViewModel()
        return AnyView(BookRootView(viewModel: viewModel, content: content))
    }

    @MainActor
    public static func getBookDisk() -> URL? {
        guard let storageRoot = BookPluginHost.getStorageRoot() else {
            return nil
        }

        let disk = storageRoot.appendingPathComponent(Self.dirName, isDirectory: true)
        return try? disk.ensureDirectory()
    }

    // MARK: - State assembly

    @MainActor
    private func installRootState(storage: any StorageProviding) {
        guard rootViewModel == nil else { return }
        let viewModel = BookRootViewModel(
            dbRootURL: { try BookPluginHost.getDBRootDir() },
            bookDisk: { Self.getBookDisk() }
        )
        let observer = BookStorageObserver(storage: storage, viewModel: viewModel)
        rootViewModel = viewModel
        rootObserver = observer
    }

    @MainActor
    private func teardownRootState() {
        rootObserver?.cancel()
        rootObserver = nil
        rootViewModel = nil
    }

    @MainActor
    private func resolveRootViewModel() -> BookRootViewModel {
        if let rootViewModel {
            return rootViewModel
        }
        let viewModel = BookRootViewModel(
            dbRootURL: { try BookPluginHost.getDBRootDir() },
            bookDisk: { Self.getBookDisk() }
        )
        rootViewModel = viewModel
        return viewModel
    }
}
