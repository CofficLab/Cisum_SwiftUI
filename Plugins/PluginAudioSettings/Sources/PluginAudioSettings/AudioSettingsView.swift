import CisumUI
import MagicKit
import OSLog
import SwiftUI

struct AudioLibraryMetrics: Equatable {
    let diskSize: String
    let fileCount: Int
}

enum AudioSettingsMetricsPolicy {
    static func shouldApplyMetrics(
        currentDisk: URL?,
        requestedDisk: URL,
        currentGeneration: Int,
        resultGeneration: Int
    ) -> Bool {
        currentDisk == requestedDisk && currentGeneration == resultGeneration
    }
}

/// 音频设置视图：展示仓库大小、位置与文件数量。
public struct AudioSettingsView: View, SuperLog {
    public nonisolated static var emoji: String { AudioSettingsPluginInfo.emoji }

    @State private var diskSize: String?
    @State private var description: String = ""
    @State private var fileCount: Int = 0
    @State private var disk: URL?
    @State private var refreshGeneration = 0

    private let refreshToken: Int
    private let audioDisk: @MainActor () -> URL?

    public init(refreshToken: Int = 0, audioDisk: @escaping @MainActor () -> URL?) {
        self.refreshToken = refreshToken
        self.audioDisk = audioDisk
    }

    public var body: some View {
        Group {
            if let disk = disk {
                AppSettingsSection(title: String(localized: "Music Library", table: "Audio-Settings", bundle: .module)) {
                    AppSettingsInfoRow(
                        title: String(localized: "Library Size", table: "Audio-Settings", bundle: .module),
                        description: description,
                        systemImage: .cisumIconMusicLibrary
                    ) {
                        if let diskSize = diskSize {
                            Text(diskSize)
                        }
                    }

                    #if os(macOS)
                        AppSettingsInfoRow(
                            title: String(localized: "Open Library", table: "Audio-Settings", bundle: .module),
                            description: String(localized: "View in Finder", table: "Audio-Settings", bundle: .module),
                            systemImage: .cisumIconShowInFinder,
                            action: {
                                disk.openInFinder()
                            }
                        ) {
                            Image(systemName: .cisumIconShowInFinder)
                        }
                    #endif

                    AppSettingsInfoRow(
                        title: String(localized: "File Count", table: "Audio-Settings", bundle: .module),
                        description: String(localized: "Total files in library", table: "Audio-Settings", bundle: .module),
                        systemImage: .cisumIconDocument
                    ) {
                        Text("\(fileCount) files", tableName: "Audio-Settings", bundle: .module)
                    }
                }
            } else {
                AppSettingsSection(title: String(localized: "Music Library", table: "Audio-Settings", bundle: .module)) {
                    AppSettingsInfoRow(
                        title: String(localized: "Error", table: "Audio-Settings", bundle: .module),
                        description: description,
                        systemImage: .cisumIconMusicLibrary
                    ) {
                        Text("Cannot get music library information", tableName: "Audio-Settings", bundle: .module)
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

private extension AudioSettingsView {
    func refresh() {
        refreshGeneration += 1
        let generation = refreshGeneration

        updateDisk()

        guard let requestedDisk = disk else {
            description = ""
            fileCount = 0
            diskSize = nil
            return
        }

        updateDescription()
        diskSize = nil
        fileCount = 0

        Task {
            let metrics = await Self.metrics(for: requestedDisk)
            await MainActor.run {
                guard AudioSettingsMetricsPolicy.shouldApplyMetrics(
                    currentDisk: self.disk,
                    requestedDisk: requestedDisk,
                    currentGeneration: self.refreshGeneration,
                    resultGeneration: generation
                ) else { return }

                self.diskSize = metrics.diskSize
                self.fileCount = metrics.fileCount
            }
        }
    }

    private func updateDisk() {
        self.disk = audioDisk()
    }

    private func updateDescription() {
        guard let disk = self.disk else {
            return
        }

        if disk.checkIsICloud(verbose: false) {
            description = String(localized: "iCloud Drive, will sync", table: "Audio-Settings", bundle: .module)
        } else {
            description = String(localized: "Local directory, will not sync", table: "Audio-Settings", bundle: .module)
        }
    }

    nonisolated static func metrics(for disk: URL) async -> AudioLibraryMetrics {
        await Task.detached(priority: .utility) {
            AudioLibraryMetrics(
                diskSize: disk.getSizeReadable(),
                fileCount: disk.filesCountRecursively()
            )
        }.value
    }
}
