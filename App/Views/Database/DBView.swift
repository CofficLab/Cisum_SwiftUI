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
                    if databaseManager.isEmpty {
                        BackgroundView.type1
                        EmptyDatabaseView()
                    } else {
                        table
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
                        databaseManager.add(urls, completionAll: {
                            appManager.setFlashMessage("添加成功")
                        })
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
                            os_log("添加 \(url.lastPathComponent) 到复制队列")
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
}

// MARK: 操作

extension DBView {
    func copy(_ files: [URL]) {
        appManager.stateMessage = "正在复制 \(files.count) 个文件"
        db.add(files,
               completionAll: {
                   appManager.setFlashMessage("已添加 \(files.count) 个文件")
                   appManager.cleanStateMessage()
               },
               completionOne: { url in
                   appManager.setFlashMessage("完成复制 \(url.lastPathComponent)")
                   dbManager.refresh()
               },
               onStart: { url in
                   AppConfig.mainQueue.sync {
                       appManager.stateMessage = "正在复制 \(url.lastPathComponent)"
                   }
               }
        )
    }
}

#Preview {
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
