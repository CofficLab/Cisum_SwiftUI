import CisumUI
import MagicKit
import OSLog
import SwiftUI

public struct StorageSettingView: View, SuperLog {
    public nonisolated static let emoji: String = "🍴"

    @Environment(\.pluginStorageDependencies) private var dependencies
    @State private var showMigrationProgress = false
    @State private var targetLocation: PluginStorageLocation
    @State private var hasChanges = false
    @State private var location: PluginStorageLocation = .local

    public init() {
        _targetLocation = State(initialValue: .local)
    }

    public var body: some View {
        AppSettingsSection(title: "Media Storage Location") {
            VStack(spacing: 0) {
                AppSettingsInfoRow(
                    title: "iCloud Drive",
                    description: "Store media files in iCloud Drive",
                    systemImage: .cisumIconCloud,
                    isSelected: location == .icloud,
                    action: {
                        beginMigration(to: .icloud)
                    }
                ) {
                    if location == .icloud {
                        Image(systemName: .cisumIconCheckmarkSimple)
                            .foregroundColor(.accentColor)
                    }
                }

                AppSettingsInfoRow(
                    title: "Local",
                    description: "Store within app, data will be lost if app is deleted",
                    systemImage: .cisumIconFolder,
                    isSelected: location == .local,
                    action: {
                        beginMigration(to: .local)
                    }
                ) {
                    if location == .local {
                        Image(systemName: .cisumIconCheckmarkSimple)
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .sheet(isPresented: $showMigrationProgress) {
            MigrationProgressView(
                sourceLocation: dependencies.getStorageLocation() ?? .local,
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
            location = dependencies.getStorageLocation() ?? location
            targetLocation = dependencies.getStorageLocation() ?? .local
        }
        .onChange(of: targetLocation) {
            hasChanges = targetLocation != (dependencies.getStorageLocation() ?? .local)
        }
        .onPluginStorageLocationChanged {
            location = dependencies.getStorageLocation() ?? location
        }
    }

    private func beginMigration(to newLocation: PluginStorageLocation) {
        guard newLocation != location else { return }

        targetLocation = newLocation
        showMigrationProgress = true
    }
}
