import Foundation
import MagicKit
import OSLog
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct AudioDBView: View, SuperLog, SuperThread, SuperEvent {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var data: DataProvider
    @EnvironmentObject var messageManager: MessageProvider
    @EnvironmentObject var s: StoreProvider
    @EnvironmentObject var db: AudioDB

    @State var treeView = false
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
            if loading {
                ProgressView()
            } else {
                VStack {
                    AudioList(verbose: false, reason: self.className)
                        .frame(maxHeight: .infinity)

                    AudioTask()
                        .shadow(radius: 10)
                }
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
        .onDrop(of: [UTType.fileURL], isTargeted: self.$isDropping, perform: onDrop)
        .task {
            self.count = await db.getTotalCount()
            self.loading = false
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
