import Foundation
import OSLog
import SwiftUI
import UniformTypeIdentifiers

struct DBView: View {
    @EnvironmentObject var app: AppManager
    
    @State var treeView = false
    
    static var label = "🐘 DBView::"

    var main = Config.mainQueue
    var bg = Config.bgQueue
    var dropping: Bool { app.isDropping }
    var label: String { "\(Logger.isMain)\(Self.label) "}
    
    init(verbose: Bool = false) {
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)初始化")
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch app.dbViewType {
                case .Tree:
                    DBViewTree()
                case .List:
                    DBViewList()
                }
            }
            .frame(maxHeight: .infinity)
            
            if Config.isDebug {
                DBBottomBar(dbViewType: $app.dbViewType)
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

extension DBView {
    func copy(_ files: [URL]) {
        Task {
//            await db.addCopyTasks(files)
        }
    }

    func setFlashMessage(_ m: String) {
        main.async {
            app.setFlashMessage(m)
            self.cleanStateMessage()
        }
    }

    func setStateMessage(_ m: String) {
        main.async {
            app.stateMessage = m
        }
    }

    func cleanStateMessage() {
        main.async {
            app.cleanStateMessage()
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
