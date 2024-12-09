import Foundation
import OSLog
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct VideoDB: View {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var data: DataProvider
    @EnvironmentObject var message: MessageProvider
    @EnvironmentObject var db: DB

    @State var treeView = false

    @Query(AudioModel.descriptorAll, animation: .default) var audios: [AudioModel]

    static var label = "🐘 DBLayout::"

    var main = Config.mainQueue
    var bg = Config.bgQueue
    var dropping: Bool { app.isDropping }
//    var disk: any SuperDisk { data.disk }
    var label: String { "\(Logger.isMain)\(Self.label) " }

    init(verbose: Bool = false) {
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)初始化")
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            VideoGrid().frame(maxHeight: .infinity)

            TaskView()
                .shadow(radius: 10)
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
        .onDrop(of: [UTType.fileURL], isTargeted: $app.isDropping) { providers -> Bool in
            let dispatchGroup = DispatchGroup()
            var dropedFiles: [URL] = []
            for provider in providers {
                dispatchGroup.enter()
                // 这是异步操作
                _ = provider.loadObject(ofClass: URL.self) { object, _ in
                    if let url = object {
                        os_log("\(Logger.isMain)🖥️ DBView::添加 \(url.lastPathComponent) 到复制队列")
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

extension VideoDB {
    func copy(_ files: [URL]) {
        data.copy(files)
    }
}

#Preview("APP") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Layout") {
    LayoutView()
}
