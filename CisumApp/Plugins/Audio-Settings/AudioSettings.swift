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
                MagicSettingSection(title: String(localized: "Music Library", table: "Audio-Settings")) {
                    MagicSettingRow(title: String(localized: "Library Size", table: "Audio-Settings"), description: description, icon: .cisumIconMusicLibrary, content: {
                        HStack {
                            if let diskSize = diskSize {
                                Text(diskSize)
                                    .font(.footnote)
                            }
                        }

                    })

                    MagicSettingRow(title: String(localized: "Open Library", table: "Audio-Settings"), description: String(localized: "View in Finder", table: "Audio-Settings"), icon: .cisumIconShowInFinder, content: {
                        Image(systemName: .cisumIconShowInFinder)
                            .frame(width: 28)
                            .frame(height: 28)
                            .background(.regularMaterial, in: .circle)
                            .cisumShadowSm()
                            .cisumHoverScale(105)
                            .cisumButton {
                                disk.openInFinder()
                            }
                    })
                    .cisumIf(Config.isDesktop)

                    MagicSettingRow(title: String(localized: "File Count", table: "Audio-Settings"), description: String(localized: "Total files in library", table: "Audio-Settings"), icon: .cisumIconDocument, content: {
                        HStack {
                            Text("\(fileCount) files", tableName: "Audio-Settings")
                                .font(.footnote)
                        }
                    })
                }
            } else {
                MagicSettingSection(title: String(localized: "Music Library", table: "Audio-Settings")) {
                    MagicSettingRow(title: String(localized: "Error", table: "Audio-Settings"), description: description, icon: .cisumIconMusicLibrary, content: {
                        Text("Cannot get music library information", tableName: "Audio-Settings")
                            .font(.footnote)
                    })
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
