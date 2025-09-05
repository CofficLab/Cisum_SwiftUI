import Foundation
import MagicCore

import OSLog
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct BookDBView: View, SuperLog, SuperThread {
    nonisolated static let emoji = "🐘"
    
    @EnvironmentObject var app: AppProvider

    @State var treeView = false
    @State var isSyncing = false
    
    // 使用 @Query 直接从 SwiftData 获取集合类型的书籍总数
    @Query(
        filter: #Predicate<BookModel> { $0.isCollection == true },
        animation: .default
    ) var books: [BookModel]
    
    // 计算属性：从 @Query 结果获取总数
    var total: Int { books.count }
    var dropping: Bool { app.isDropping }
    
    private var useListView = false

    var body: some View {
        os_log("\(self.t)开始渲染")
        return VStack(spacing: 0) {
            HStack {
                Text("共 \(total.description)")
                Spacer()
                if isSyncing {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("正在读取仓库")
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 5)

            if useListView {
                BookList()
            } else {
                BookGrid()
            }
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
        .onBookDBSyncing {
            self.isSyncing = true
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

// MARK: - Preview

#if os(macOS)
#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 600, height: 600)
}
#endif

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif


