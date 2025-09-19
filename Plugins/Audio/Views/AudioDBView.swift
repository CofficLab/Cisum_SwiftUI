import Foundation
import MagicCore
import OSLog
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

@MainActor
struct AudioDBView: View, SuperLog, SuperThread, SuperEvent {
    static let verbose = false

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var audioProvider: AudioProvider

    @State private var isSorting: Bool = false
    @State private var sortMode: SortMode = .none

    nonisolated static let emoji = "🐘"

    private func fetchStorageRoot() async -> URL {
        let database = audioProvider.disk
        return await withCheckedContinuation { continuation in
            Task {
                let root = database
                continuation.resume(returning: root)
            }
        }
    }

    var body: some View {
        if Self.verbose {
            os_log("\(self.t)开始渲染")
        }

        return AudioList()
            .overlay(alignment: .center) {
                if isSorting {
                    AudioSortingTips(sortModeIcon: sortMode.icon, description: sortMode.description, isAnimating: isSorting)
                        .transition(.opacity)
                }
            }
            .frame(maxHeight: .infinity)
            .fileImporter(
                isPresented: $app.isImporting,
                allowedContentTypes: [.audio],
                allowsMultipleSelection: true,
                onCompletion: handleFileImport
            )
            .onDBSorting(perform: onSorting)
            .onDBSortDone(perform: onSortDone)
    }
}

extension AudioDBView {
    enum SortMode: String {
        case random, order, none

        var icon: String {
            switch self {
            case .random: return "shuffle"
            case .order: return "arrow.up.arrow.down"
            case .none: return "arrow.triangle.2.circlepath"
            }
        }

        var description: String {
            switch self {
            case .random: return "正在随机排序..."
            case .order: return "正在顺序排序..."
            case .none: return "正在排序..."
            }
        }
    }

    private func handleFileImport(result: Result<[URL], Error>) {
        Task {
            switch result {
            case let .success(urls):
                os_log("\(self.t)🍋🍋🍋 handleFileImport, urls: \(urls.count)")
                let storageRoot = await fetchStorageRoot()
                self.emit(name: .CopyFiles, object: self, userInfo: [
                    "urls": urls,
                    "folder": storageRoot,
                ])

                for url in urls {
                    try await url.copyTo(storageRoot.appendingPathComponent(url.lastPathComponent), caller: self.className)
                }
            case let .failure(error):
                os_log(.error, "导入文件失败Error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Event Handler

extension AudioDBView {
    func onSorting(_ notification: Notification) {
        os_log("\(t)🍋 onSorting")
        withAnimation { isSorting = true }
        if let mode = notification.userInfo?["mode"] as? String {
            sortMode = SortMode(rawValue: mode) ?? .none
        }
    }

    func onSortDone(_ notification: Notification) {
        os_log("\(t)🍋 onSortDone")
        withAnimation { isSorting = false }
    }
}

#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 600, height: 600)
}

#if os(iOS)
    #Preview("iPhone") {
        AppPreview()
    }
#endif
