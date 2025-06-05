import MagicCore
import SwiftUI

import OSLog

struct SettingPluginView: View, SuperSetting, SuperLog {
    nonisolated static let emoji: String = "🍴"

    @EnvironmentObject var cloudManager: CloudProvider
    @EnvironmentObject var c: ConfigProvider

    @State private var showMigrationProgress = false
    @State private var tempStorageLocation: StorageLocation
    @State private var hasChanges = false
    @State private var storageRoot: URL?

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
                    if c.storageLocation == .icloud {
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
                    if c.storageLocation == .local {
                        Image(systemName: .iconCheckmarkSimple)
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .sheet(isPresented: $showMigrationProgress) {
            MigrationProgressView(
                sourceLocation: c.storageLocation ?? .local,
                targetLocation: tempStorageLocation,
                sourceURL: c.getStorageRoot(),
                targetURL: c.getStorageRoot(for: tempStorageLocation),
                onDismiss: {
                    showMigrationProgress = false
                    self.hasChanges = tempStorageLocation != c.storageLocation
                    storageRoot = c.getStorageRoot()

                    os_log("\(self.t) Current Storage Root \(storageRoot?.path ?? "nil")")
                }
            )
        }.onAppear {
            tempStorageLocation = c.storageLocation ?? .local
            hasChanges = false
            storageRoot = c.getStorageRoot()
            
            os_log("\(self.t) Current Storage Type: \(c.storageLocation?.rawValue ?? "nil")")
        }
        .onChange(of: tempStorageLocation) {
            hasChanges = tempStorageLocation != (c.storageLocation ?? .local)
            storageRoot = c.getStorageRoot()
        }
        .onChange(of: c.storageLocation) {
            hasChanges = tempStorageLocation != (c.storageLocation ?? .local)
            storageRoot = c.getStorageRoot()
        }
    }
}

#Preview {
    AppPreview()
}

#Preview("Setting") {
    RootView {
        SettingView()
            .background(.background)
    }
    .frame(height: 1200)
}
