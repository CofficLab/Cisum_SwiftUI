import Foundation
import OSLog
import SwiftUI
import UniformTypeIdentifiers

struct DBView: View {
    @EnvironmentObject var dbManager: DBManager
    @EnvironmentObject var appManager: AppManager

    @State private var dropping: Bool = false

    var db: DBModel { dbManager.dbModel }

    var body: some View {
        #if os(iOS)
            NavigationView {
                ZStack {
                    if dbManager.isEmpty {
                        BackgroundView.type1
                        DBEmptyView()
                    } else {
                        DBTableView()
                    }
                }
                .toolbar {
                    ButtonAdd()
                }
            }
            .fileImporter(
                isPresented: $appManager.isImporting,
                allowedContentTypes: [.audio],
                allowsMultipleSelection: true,
                onCompletion: { result in
                    switch result {
                    case let .success(urls):
                        copy(urls)
                    case let .failure(error):
                        print("导入文件失败Error: \(error)")
                    }
                })
        #else
            ZStack {
                DBTableView()

                if dbManager.isEmpty && appManager.flashMessage.isEmpty {
                    DBEmptyView()
                }
            }
            .onChange(of: dropping, perform: { v in
                appManager.setFlashMessage(v ? "松开可添加文件" : "")
            })
            .onDrop(of: [UTType.fileURL], isTargeted: $dropping) { providers -> Bool in
                let dispatchGroup = DispatchGroup()
                var dropedFiles: [URL] = []
                for provider in providers {
                    dispatchGroup.enter()
                    // 这是异步操作
                    _ = provider.loadObject(ofClass: URL.self) { object, _ in
                        if let url = object {
                            os_log("🖥️ DBView::添加 \(url.lastPathComponent) 到复制队列")
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
        #endif
    }
    
    init() {
        os_log("🚩 DBView::Init")
    }
}

// MARK: 操作

extension DBView {
    func copy(_ files: [URL]) {
        appManager.stateMessage = "🖥️ DBView::正在复制 \(files.count) 个文件"
        db.add(files,
               completionAll: {
                   AppConfig.mainQueue.sync {
                       appManager.setFlashMessage("已添加 \(files.count) 个文件")
                       appManager.cleanStateMessage()
                       dbManager.refresh()
                       os_log("🖥️ DBView::添加完成 🎉🎉🎉")
                   }
               },
               completionOne: { url in
                   AppConfig.mainQueue.async {
                       appManager.setFlashMessage("完成复制 \(url.lastPathComponent)")
                       dbManager.refresh()
                       os_log("🖥️ DBView::添加完成 🎉🎉🎉 -> \(url.lastPathComponent)")
                   }
               },
               onStart: { url in
                   AppConfig.mainQueue.sync {
                       if AudioModel(url).isNotDownloaded {
                           appManager.stateMessage = "正在从 iCloud 下载 \(url.lastPathComponent)"
                       } else {
                           appManager.stateMessage = "正在复制 \(url.lastPathComponent)"
                       }
                   }
               }
        )
    }
}

#Preview("APP") {
    RootView {
        DBView()
    }
}

#Preview {
    RootView {
        DBView().frame(width: 300)
    }
}

#Preview {
    RootView {
        DBView().frame(width: 350)
    }
}

#Preview {
    RootView {
        DBView().frame(width: 400)
    }
}

#Preview {
    RootView {
        DBView().frame(width: 500)
    }
}

#Preview {
    RootView {
        DBView().frame(width: 600)
    }
}
