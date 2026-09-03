import CisumUIComponents
import OSLog
import ProviderStorage
import SwiftUI

public struct StorageSettingView: View, SuperLog {
    public nonisolated static let emoji: String = "🍴"

    @Environment(\.pluginStorageDependencies) private var dependencies
    @StateObject private var viewModel: StorageSettingsViewModel
    @State private var showMigrationProgress = false
    @State private var targetLocation: StoragePluginLocation
    @State private var hasChanges = false
    @State private var location: StoragePluginLocation?

    public init(storage: (any StorageProviding)? = nil) {
        _viewModel = StateObject(wrappedValue: StorageSettingsViewModel(storage: storage))
        _targetLocation = State(initialValue: .local)
    }

    public var body: some View {
        AppSettingSection(title: String(localized: "Media Storage Location", bundle: .module)) {
            VStack(spacing: 0) {
                AppSettingRow(
                    title: String(localized: "iCloud Drive", bundle: .module),
                    description: viewModel.isICloudAvailable
                        ? String(localized: "Store media files in iCloud Drive", bundle: .module)
                        : String(localized: "iCloud Drive is unavailable", bundle: .module),
                    icon: .cisumIconCloud,
                    action: viewModel.isICloudAvailable ? {
                        beginMigration(to: .icloud)
                    } : nil
                ) {
                    if location == .icloud {
                        Image(systemName: .cisumIconCheckmarkSimple)
                            .foregroundColor(.accentColor)
                    } else if !viewModel.isICloudAvailable {
                        Text("Unavailable", bundle: .module)
                            .font(.footnote)
                    }
                }
                .opacity(viewModel.isICloudAvailable ? 1 : 0.5)

                AppSettingRow(
                    title: String(localized: "Local", bundle: .module),
                    description: viewModel.isLocalStorageAvailable
                        ? String(localized: "Store within app, data will be lost if app is deleted", bundle: .module)
                        : String(localized: "Local storage is unavailable", bundle: .module),
                    icon: .cisumIconFolder,
                    action: viewModel.isLocalStorageAvailable ? {
                        beginMigration(to: .local)
                    } : nil
                ) {
                    if location == .local {
                        Image(systemName: .cisumIconCheckmarkSimple)
                            .foregroundColor(.accentColor)
                    } else if !viewModel.isLocalStorageAvailable {
                        Text("Unavailable", bundle: .module)
                            .font(.footnote)
                    }
                }
                .opacity(viewModel.isLocalStorageAvailable ? 1 : 0.5)
            }
        }
        .sheet(isPresented: $showMigrationProgress) {
            MigrationProgressView(
                sourceLocation: dependencies.getStorageLocation(),
                targetLocation: targetLocation,
                sourceURL: dependencies.getStorageRoot(),
                targetURL: dependencies.getStorageRootForLocation(targetLocation),
                onDismiss: {
                    showMigrationProgress = false
                    self.hasChanges = targetLocation != dependencies.getStorageLocation()
                }
            )
        }
        .onAppear {
            applyStorageLocationUpdate(viewModel.location)
        }
        .onChange(of: targetLocation) {
            hasChanges = Self.hasSelectionChanges(
                targetLocation: targetLocation,
                storageLocation: dependencies.getStorageLocation()
            )
        }
        .onChange(of: viewModel.location) { _, newLocation in
            applyStorageLocationUpdate(newLocation)
        }
        .onStoragePluginLocationChanged {
            applyStorageLocationUpdate(viewModel.location)
        }
    }

    private func applyStorageLocationUpdate(_ storageLocation: StoragePluginLocation?) {
        let state = Self.stateAfterStorageUpdate(
            currentTarget: targetLocation,
            storageLocation: storageLocation
        )
        location = storageLocation
        targetLocation = state.targetLocation
        hasChanges = state.hasChanges
    }

    private func beginMigration(to newLocation: StoragePluginLocation) {
        guard newLocation != location else { return }
        guard dependencies.getStorageRootForLocation(newLocation) != nil else { return }

        targetLocation = newLocation
        showMigrationProgress = true
    }

    private var isICloudAvailable: Bool {
        dependencies.getStorageRootForLocation(.icloud) != nil
    }

    private var isLocalStorageAvailable: Bool {
        dependencies.getStorageRootForLocation(.local) != nil
    }

    nonisolated static func targetLocationAfterStorageUpdate(
        currentTarget: StoragePluginLocation,
        storageLocation: StoragePluginLocation?
    ) -> StoragePluginLocation {
        storageLocation ?? currentTarget
    }

    nonisolated static func stateAfterStorageUpdate(
        currentTarget: StoragePluginLocation,
        storageLocation: StoragePluginLocation?
    ) -> (targetLocation: StoragePluginLocation, hasChanges: Bool) {
        let targetLocation = targetLocationAfterStorageUpdate(
            currentTarget: currentTarget,
            storageLocation: storageLocation
        )
        return (
            targetLocation,
            hasSelectionChanges(
                targetLocation: targetLocation,
                storageLocation: storageLocation
            )
        )
    }

    nonisolated static func hasSelectionChanges(
        targetLocation: StoragePluginLocation,
        storageLocation: StoragePluginLocation?
    ) -> Bool {
        storageLocation.map { targetLocation != $0 } ?? false
    }
}
