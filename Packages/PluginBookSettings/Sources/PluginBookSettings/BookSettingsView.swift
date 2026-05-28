import CisumUI
import MagicKit
import OSLog
import SwiftUI

/// 有声书设置视图：展示仓库大小、位置与文件数量。
public struct BookSettingsView: View, SuperLog {
    public nonisolated static var emoji: String { BookSettingsPluginInfo.emoji }

    @State private var diskSize: String?
    @State private var description: String = ""
    @State private var fileCount: Int = 0
    @State private var disk: URL?

    private let refreshToken: Int
    private let bookDisk: @MainActor () -> URL?

    public init(refreshToken: Int = 0, bookDisk: @escaping @MainActor () -> URL?) {
        self.refreshToken = refreshToken
        self.bookDisk = bookDisk
    }

    public var body: some View {
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
            refresh()
        }
        .onChange(of: refreshToken) {
            refresh()
        }
    }
}

// MARK: - Action

private extension BookSettingsView {
    func refresh() {
        updateDisk()
        updateDescription()
        updateFileCount()
        updateDiskSize()
    }

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
        self.disk = bookDisk()
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
