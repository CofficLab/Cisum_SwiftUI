import MagicCore
import SwiftUI

import OSLog

struct SettingPluginView: View, SuperLog {
    nonisolated static let emoji: String = "🍴"

    @EnvironmentObject var cloudManager: CloudProvider

    @State private var showMigrationProgress = false
    @State private var tempStorageLocation: StorageLocation
    @State private var hasChanges = false
    @State private var storageRoot: URL?
    @State private var location: StorageLocation = .local

    init() {
        _tempStorageLocation = State(initialValue: .local)
    }

    var body: some View {
        MagicSettingSection(title: "媒体仓库位置") {
            VStack(spacing: 0) {
                MagicSettingRow(
                    title: "iCloud 云盘",
                    description: "将媒体文件存储在 iCloud 云盘中",
                    icon: .iconCloud,
                    action: {
                        showMigrationProgress = true
                        tempStorageLocation = .icloud
                    }
                ) {
                    if location == .icloud {
                        Image(systemName: .iconCheckmarkSimple)
                            .foregroundColor(.accentColor)
                    }
                }
                Divider().padding(5)

                MagicSettingRow(
                    title: "本机",
                    description: "存储在 APP 中，删除 APP 后数据将丢失",
                    icon: .iconFolder,
                    action: {
                        showMigrationProgress = true
                        tempStorageLocation = .local
                    }
                ) {
                    if location == .local {
                        Image(systemName: .iconCheckmarkSimple)
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .sheet(isPresented: $showMigrationProgress) {
            MigrationProgressView(
                sourceLocation: Config.getStorageLocation() ?? .local,
                targetLocation: tempStorageLocation,
                sourceURL: Config.getStorageRoot(),
                targetURL: Config.getStorageRoot(for: tempStorageLocation),
                onDismiss: {
                    showMigrationProgress = false
                    self.hasChanges = tempStorageLocation != Config.getStorageLocation()
                    storageRoot = Config.getStorageRoot()

                    os_log("\(self.t) Current Storage Root \(storageRoot?.path ?? "nil")")
                }
            )
        }.onAppear {
            location = Config.getStorageLocation() ?? location
            tempStorageLocation = Config.getStorageLocation() ?? .local
            hasChanges = false
            storageRoot = Config.getStorageRoot()
            
            os_log("\(self.t) Current Storage Type: \(Config.getStorageLocation()?.rawValue ?? "nil")")
        }
        .onChange(of: tempStorageLocation) {
            hasChanges = tempStorageLocation != (Config.getStorageLocation() ?? .local)
            storageRoot = Config.getStorageRoot()
        }
        .onChange(of: Config.getStorageLocation()) {
            hasChanges = tempStorageLocation != (Config.getStorageLocation() ?? .local)
            storageRoot = Config.getStorageRoot()
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
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 500, height: 800)
}
#endif

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif
