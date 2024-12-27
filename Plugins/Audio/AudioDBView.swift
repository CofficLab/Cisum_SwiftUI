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
