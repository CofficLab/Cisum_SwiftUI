import Foundation
import MagicKit

import OSLog
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

@MainActor
struct AudioDBView: View, SuperLog, SuperThread, SuperEvent {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var messageManager: MessageProvider
    @EnvironmentObject var s: StoreProvider
    @EnvironmentObject var db: AudioDB

    @State var isDropping: Bool = false

    nonisolated static let emoji = "🐘"

    private func fetchStorageRoot() async -> URL {
        let database = db
        return await withCheckedContinuation { continuation in
            Task {
                let root = await database.getStorageRoot()
                continuation.resume(returning: root)
            }
        }
    }

    var body: some View {
        AudioList2()
            .frame(maxHeight: .infinity)
            .fileImporter(
                isPresented: $app.isImporting,
                allowedContentTypes: [.audio],
                allowsMultipleSelection: true,
                onCompletion: handleFileImport
            )
    }
}

extension AudioDBView {
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
