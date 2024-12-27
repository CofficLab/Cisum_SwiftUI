import Foundation
import MagicKit
import OSLog
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct BookDBView: View, SuperLog, SuperThread {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var bookManager: BookProvider
    @EnvironmentObject var db: BookDB

    @State var treeView = false
    @State var total: Int = 0

    static var emoji = "🐘"

    var dropping: Bool { app.isDropping }
    var disk: any SuperStorage

    init(verbose: Bool = false, disk: any SuperStorage) {
        if verbose {
            os_log("\(Logger.initLog)BookDBView")
        }

        self.disk = disk
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("共 \(total.description)")
                Spacer()
                if bookManager.isSyncing {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("正在读取仓库")
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 5)

            BookGrid()
                .frame(maxHeight: .infinity)
        }
        .fileImporter(
            isPresented: $app.isImporting,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: true,
            onCompletion: { result in
                switch result {
                case let .success(urls):
                    copy(urls)
                case let .failure(error):
                    os_log(.error, "导入文件失败Error: \(error.localizedDescription)")
                }
            }
        )
        .task {
            self.total = await db.getTotal()
        }
        .onDrop(of: [UTType.fileURL], isTargeted: $app.isDropping) { providers -> Bool in
            let dispatchGroup = DispatchGroup()
            var dropedFiles: [URL] = []
            for provider in providers {
                dispatchGroup.enter()
                // 这是异步操作
                _ = provider.loadObject(ofClass: URL.self) { object, _ in
                    if let url = object {
                        os_log("\(self.t)添加 \(url.lastPathComponent) 到复制队列")
                        dropedFiles.append(url)
                    }

                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                copy(dropedFiles)
            }

            return true
        }
    }
}

// MARK: 操作

extension BookDBView {
    func copy(_ files: [URL]) {

    }
}

#Preview("APP") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Layout") {
    LayoutView()
}
