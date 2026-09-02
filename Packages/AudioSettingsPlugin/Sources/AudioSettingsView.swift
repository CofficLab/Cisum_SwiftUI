import CisumUI
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

enum AudioSettingsFileCountTextPolicy {
    static func shouldUseSingular(_ count: Int) -> Bool {
        count == 1
    }
}

/// 音频设置视图：展示仓库大小、位置与文件数量。
public struct AudioSettingsView: View, SuperLog {
    public nonisolated static var emoji: String { AudioSettingsPluginInfo.emoji }
    nonisolated static let openLibraryActionLabel = String(
        localized: "Open Library",
        bundle: .module
    )

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
                CisumUI.MagicSettingSection(title: String(localized: "Music Library", bundle: .module)) {
                    CisumUI.MagicSettingRow(
                        title: String(localized: "Library Size", bundle: .module),
                        description: description,
                        icon: .cisumIconMusicLibrary
                    ) {
                        if let diskSize = diskSize {
                            Text(diskSize)
                                .font(.footnote)
                        }
                    }

                    #if os(macOS)
                        if Self.shouldShowOpenLibraryAction(for: disk) {
                            CisumUI.MagicSettingRow(
                                title: String(localized: "Open Library", bundle: .module),
                                description: String(localized: "View in Finder", bundle: .module),
                                icon: .cisumIconShowInFinder
                            ) {
                                Image(systemName: .cisumIconShowInFinder)
                                    .frame(width: 28, height: 28)
                                    .background(.regularMaterial, in: Circle())
                                    .cisumShadowSm()
                                    .cisumHoverScale(105)
                                    .cisumButton {
                                        disk.openInFinder()
                                    }
                                    .accessibilityLabel(Self.openLibraryActionLabel)
                                    .help(Self.openLibraryActionLabel)
                            }
                        }
                    #endif

                    CisumUI.MagicSettingRow(
                        title: String(localized: "File Count", bundle: .module),
                        description: String(localized: "Total files in library", bundle: .module),
                        icon: .cisumIconDocument
                    ) {
                        if Self.shouldUseSingularFileCount(fileCount) {
                            Text("\(fileCount) file", bundle: .module)
                                .font(.footnote)
                        } else {
                            Text("\(fileCount) files", bundle: .module)
                                .font(.footnote)
                        }
                    }
                }
            } else {
                CisumUI.MagicSettingSection(title: String(localized: "Music Library", bundle: .module)) {
                    CisumUI.MagicSettingRow(
                        title: String(localized: "Error", bundle: .module),
                        description: description,
                        icon: .cisumIconMusicLibrary
                    ) {
                        Text("Cannot get music library information", bundle: .module)
                            .font(.footnote)
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
            description = String(localized: "iCloud Drive, will sync", bundle: .module)
        } else {
            description = String(localized: "Local directory, will not sync", bundle: .module)
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

extension AudioSettingsView {
    nonisolated static func shouldShowOpenLibraryAction(for disk: URL) -> Bool {
        URLOpenActionPolicy.canOpen(disk)
    }

    nonisolated static func shouldUseSingularFileCount(_ count: Int) -> Bool {
        AudioSettingsFileCountTextPolicy.shouldUseSingular(count)
    }
}
