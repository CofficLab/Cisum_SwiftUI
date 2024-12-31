import Foundation
import MagicKit
import MagicUI
import OSLog
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct AudioDBView: View, SuperLog, SuperThread, SuperEvent {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var messageManager: MessageProvider
    @EnvironmentObject var s: StoreProvider
    @EnvironmentObject var db: AudioDB

    @State var treeView = false
    @State var isDropping: Bool = false
    @State var count: Int = 0
    @State var loading: Bool = true

    static let emoji = "🐘"

    init(verbose: Bool, reason: String) {
        if verbose {
            os_log("\(Self.i) 🐛 \(reason)")
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
                }
            }
        }
        .fileImporter(
            isPresented: $app.isImporting,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: true,
            onCompletion: handleFileImport
        )
        .task {
            self.count = await db.getTotalCount()
            self.loading = false
        }
    }
}

extension AudioDBView {
    private func handleFileImport(result: Result<[URL], Error>) {
        Task {
            switch result {
            case let .success(urls):
                os_log("\(self.t)🍋🍋🍋 handleFileImport, urls: \(urls.count)")
                await self.emit(name: .CopyFiles, object: self, userInfo: [
                    "urls": urls,
                    "folder": self.db.getStorageRoot()
                ])
            case let .failure(error):
                os_log(.error, "导入文件失败Error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: Event Name

extension Notification.Name {
    static let CopyFiles = Notification.Name("CopyFiles")
}

#Preview("APP") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Layout") {
    LayoutView()
}
