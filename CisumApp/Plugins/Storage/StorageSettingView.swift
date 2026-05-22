import CisumUI
import SwiftUI

import OSLog

struct StorageSettingView: View, SuperLog {
    nonisolated static let emoji: String = "🍴"

    @EnvironmentObject var cloudManager: CloudProvider

    @State private var showMigrationProgress = false
    @State private var targetLocation: StorageLocation
    @State private var hasChanges = false
    @State private var location: StorageLocation = .local

    init() {
        _targetLocation = State(initialValue: .local)
    }

    var body: some View {
        AppSettingsSection(title: "Media Storage Location") {
            VStack(spacing: 0) {
                AppSettingsInfoRow(
                    title: "iCloud Drive",
                    description: "Store media files in iCloud Drive",
                    systemImage: .cisumIconCloud,
                    isSelected: location == .icloud,
                    action: {
                        showMigrationProgress = true
                        targetLocation = .icloud
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
                        showMigrationProgress = true
                        targetLocation = .local
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
                sourceLocation: Config.getStorageLocation() ?? .local,
                targetLocation: targetLocation,
                sourceURL: Config.getStorageRoot(),
                targetURL: Config.getStorageRoot(for: targetLocation),
                onDismiss: {
                    showMigrationProgress = false
                    self.hasChanges = targetLocation != Config.getStorageLocation()
                }
            )
        }
        .onAppear {
            location = Config.getStorageLocation() ?? location
            targetLocation = Config.getStorageLocation() ?? .local
        }
        .onChange(of: targetLocation) {
            hasChanges = targetLocation != (Config.getStorageLocation() ?? .local)
        }
        .onStorageLocationChanged {
            location = Config.getStorageLocation() ?? location
        }
    }
}

#Preview("Setting") {
    RootView {
        SettingView()
            .background(.background)
    }
    .frame(height: 800)
}

// MARK: - Preview

#if os(macOS)
    #Preview("App - Large") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        ContentView()
            .inRootView()
            .frame(width: 500, height: 800)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
            .inRootView()
    }
#endif
