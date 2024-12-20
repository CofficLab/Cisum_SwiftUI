import Foundation
import MagicKit
import OSLog
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct AudioDBView: View, SuperLog, SuperThread {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var data: DataProvider
    @EnvironmentObject var messageManager: MessageProvider
    @EnvironmentObject var s: StoreProvider
    @EnvironmentObject var db: AudioDB

    @State var treeView = false
    @State var isSorting = false
    @State var sortMode: SortMode = .none
    @State var isDropping: Bool = false
    @State var count: Int = 0
    @State var loading: Bool = true

    let emoji = "🐘"

    var showProTips: Bool {
        count >= Config.maxAudioCount && s.currentSubscription == nil && isDropping
    }

    var showTips: Bool {
        if loading {
            return false
        }

        return (isDropping || (messageManager.flashMessage.isEmpty && count == 0)) && !showProTips
    }

    var outOfLimit: Bool {
        count >= Config.maxAudioCount && s.currentSubscription == nil
    }

    init(verbose: Bool, reason: String) {
        if verbose {
            os_log("\(Logger.isMain)AudioDBView 🐛 \(reason)")
        }
    }

    var body: some View {
        ZStack {
            VStack {
                AudioList(verbose: false, reason: self.className)
                    .frame(maxHeight: .infinity)

                AudioTask()
                    .shadow(radius: 10)
            }

            if isSorting {
                Text(sortMode.description)
            }

            if loading {
                ProgressView()
            }

            if showTips {
                AudioDBTips()
            }

            if showProTips {
                AudioProTips()
            }
        }
        .fileImporter(
            isPresented: $app.isImporting,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: true,
            onCompletion: handleFileImport
        )
        .onReceive(NotificationCenter.default.publisher(for: .DBSorting), perform: onSorting)
        .onReceive(NotificationCenter.default.publisher(for: .DBSortDone), perform: onSortDone)
        .onDrop(of: [UTType.fileURL], isTargeted: self.$isDropping, perform: onDrop)
        .task {
            self.count = await db.getTotalCount()
            self.loading = false
        }
    }
}

// MARK: - Enums

extension AudioDBView {
    enum SortMode: String {
        case random, order, none

        var description: String {
            switch self {
            case .random: return "正在随机排序..."
            case .order: return "正在顺序排序..."
            case .none: return "正在排序..."
            }
        }
    }
}

// MARK: - Helper Methods

extension AudioDBView {
    private func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case let .success(urls):
            emitCopyFiles(urls)
        case let .failure(error):
            os_log(.error, "导入文件失败Error: \(error.localizedDescription)")
        }
    }
}

// MARK: - Event Handlers

extension AudioDBView {
    func onDrop(_ providers: [NSItemProvider]) -> Bool {
        if outOfLimit {
            return false
        }

        // Extract URLs from providers on the main thread
        let urls = providers.compactMap { provider -> URL? in
            var result: URL?
            let semaphore = DispatchSemaphore(value: 0)

            _ = provider.loadObject(ofClass: URL.self) { url, _ in
                result = url
                semaphore.signal()
            }

            semaphore.wait()
            return result
        }

        // Process the extracted URLs on the background queue
        bg.async {
            os_log("\(Logger.isMain)🖥️ DBView::添加 \(urls.count) 个文件到复制队列")
            self.emitCopyFiles(urls)
        }

        return true
    }

    func onSorting(_ notification: Notification) {
        os_log("\(t)onSorting")
        isSorting = true
        if let mode = notification.userInfo?["mode"] as? String {
            sortMode = SortMode(rawValue: mode) ?? .none
        }
    }

    func onSortDone(_ notification: Notification) {
        os_log("\(t)onSortDone")
        isSorting = false
    }
}

// MARK: Event Name

extension Notification.Name {
    static let CopyFiles = Notification.Name("CopyFiles")
}

// MARK: Event Emit

extension AudioDBView {
    func emitCopyFiles(_ urls: [URL]) {
        self.main.async {
            NotificationCenter.default.post(name: .CopyFiles, object: self, userInfo: ["urls": urls])
        }
    }
}

#Preview("APP") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Layout") {
    LayoutView()
}
