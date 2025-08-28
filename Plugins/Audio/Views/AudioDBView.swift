import Foundation
import MagicCore

import OSLog
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

@MainActor
struct AudioDBView: View, SuperLog, SuperThread, SuperEvent {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var audioProvider: AudioProvider

    @State var isDropping: Bool = false

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
        os_log("\(self.t)开始渲染")
        return AudioList()
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




