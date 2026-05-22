import CisumUI
import MagicKit
import OSLog
import SwiftUI

/// 音频设置视图：展示仓库大小、位置与文件数量。
struct AudioSettings: View, SuperLog {
    nonisolated static let emoji = "🔊"

    @State var diskSize: String?
    @State var description: String = ""
    @State var fileCount: Int = 0
    @State var disk: URL? = nil

    var body: some View {
        Group {
            if let disk = disk {
                AppSettingsSection(title: String(localized: "Music Library", table: "Audio-Settings")) {
                    AppSettingsInfoRow(title: String(localized: "Library Size", table: "Audio-Settings"), description: description, systemImage: .iconMusicLibrary) {
                        if let diskSize = diskSize {
                            Text(diskSize)
                        }
                    }

                    AppSettingsInfoRow(title: String(localized: "Open Library", table: "Audio-Settings"), description: String(localized: "View in Finder", table: "Audio-Settings"), systemImage: .iconShowInFinder, action: {
                        disk.openInFinder()
                    }) {
                        Image(systemName: .iconShowInFinder)
                    }
                    .if(Config.isDesktop)

                    AppSettingsInfoRow(title: String(localized: "File Count", table: "Audio-Settings"), description: String(localized: "Total files in library", table: "Audio-Settings"), systemImage: .iconDocument) {
                        Text("\(fileCount) files", tableName: "Audio-Settings")
                    }
                }
            } else {
                AppSettingsSection(title: String(localized: "Music Library", table: "Audio-Settings")) {
                    AppSettingsInfoRow(title: String(localized: "Error", table: "Audio-Settings"), description: description, systemImage: .iconMusicLibrary) {
                        Text("Cannot get music library information", tableName: "Audio-Settings")
                    }
                }
            }
        }
        .task {
            self.updateDisk()
            self.updateDescription()
            self.updateFileCount()
            self.updateDiskSize()
        }
        .onStorageLocationChanged {
            self.updateDisk()
            self.updateDescription()
            self.updateFileCount()
            self.updateDiskSize()
        }
    }
}

// MARK: - Action

extension AudioSettings {
    private func updateDiskSize() {
        guard let disk = self.disk else {
            return
        }

        self.diskSize = disk.getSizeReadable()
    }

    private func updateFileCount() {
        guard let disk = self.disk else {
            return
        }

        self.fileCount = disk.filesCountRecursively()
    }

    private func updateDisk() {
        self.disk = AudioPlugin.getAudioDisk()
    }

    private func updateDescription() {
        guard let disk = self.disk else {
            return
        }

        if disk.checkIsICloud(verbose: false) {
            description = String(localized: "iCloud Drive, will sync", table: "Audio-Settings")
        } else {
            description = String(localized: "Local directory, will not sync", table: "Audio-Settings")
        }
    }
}

// MARK: - Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
