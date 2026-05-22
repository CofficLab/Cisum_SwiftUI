import CisumUI
import OSLog
import SwiftUI

/// 有声书设置视图：展示仓库大小、位置与文件数量。
struct BookSettings: View, SuperLog {
    nonisolated static let emoji = "🔊"

    @State var diskSize: String?
    @State var description: String = ""
    @State var fileCount: Int = 0
    @State var disk: URL? = nil

    var body: some View {
        Group {
            if let disk = disk {
                AppSettingsSection(title: "Audiobook Library") {
                    AppSettingsInfoRow(title: "Library Size", description: description, systemImage: .cisumIconMusicLibrary) {
                        if let diskSize = diskSize {
                            Text(diskSize)
                        }
                    }

                    #if os(macOS)
                        AppSettingsInfoRow(title: "Open Library", description: "View in Finder", systemImage: .cisumIconShowInFinder, action: {
                            disk.openInFinder()
                        }) {
                            Image(systemName: .cisumIconShowInFinder)
                        }
                    #endif

                    AppSettingsInfoRow(title: "File Count", description: "Total files in library", systemImage: .cisumIconDocument) {
                        Text("\(fileCount) files")
                    }
                }
            } else {
                AppSettingsSection(title: "Music Library") {
                    AppSettingsInfoRow(title: "Error", description: description, systemImage: .cisumIconMusicLibrary) {
                        Text("Cannot get music library information")
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

extension BookSettings {
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
        self.disk = BookPlugin.getBookDisk()
    }

    private func updateDescription() {
        guard let disk = self.disk else {
            return
        }

        if disk.checkIsICloud(verbose: false) {
            description = "iCloud Drive, will sync"
        } else {
            description = "Local directory, will not sync"
        }
    }
}

// MARK: - Preview

#Preview("Setting") {
    RootView {
        SettingView()
            .background(.background)
    }
    .frame(height: 800)
}

#if os(macOS)
    #Preview("App - Large") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 600)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
            .inRootView()
    }
#endif
