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
                AppSettingsSection(title: String(localized: "Audiobook Library", table: "Book-Settings", bundle: .module)) {
                    AppSettingsInfoRow(
                        title: String(localized: "Library Size", table: "Book-Settings", bundle: .module),
                        description: description,
                        systemImage: .cisumIconMusicLibrary
                    ) {
                        if let diskSize = diskSize {
                            Text(diskSize)
                        }
                    }

                    #if os(macOS)
                        AppSettingsInfoRow(
                            title: String(localized: "Open Library", table: "Book-Settings", bundle: .module),
                            description: String(localized: "View in Finder", table: "Book-Settings", bundle: .module),
                            systemImage: .cisumIconShowInFinder,
                            action: {
                                disk.openInFinder()
                            }
                        ) {
                            Image(systemName: .cisumIconShowInFinder)
                        }
                    #endif

                    AppSettingsInfoRow(
                        title: String(localized: "File Count", table: "Book-Settings", bundle: .module),
                        description: String(localized: "Total files in library", table: "Book-Settings", bundle: .module),
                        systemImage: .cisumIconDocument
                    ) {
                        Text("\(fileCount) files", tableName: "Book-Settings", bundle: .module)
                    }
                }
            } else {
                AppSettingsSection(title: String(localized: "Audiobook Library", table: "Book-Settings", bundle: .module)) {
                    AppSettingsInfoRow(
                        title: String(localized: "Error", table: "Book-Settings", bundle: .module),
                        description: description,
                        systemImage: .cisumIconMusicLibrary
                    ) {
                        Text("Cannot get audiobook library information", tableName: "Book-Settings", bundle: .module)
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

        guard disk != nil else {
            description = ""
            fileCount = 0
            diskSize = nil
            return
        }

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
            description = String(localized: "iCloud Drive, will sync", table: "Book-Settings", bundle: .module)
        } else {
            description = String(localized: "Local directory, will not sync", table: "Book-Settings", bundle: .module)
        }
    }
}
