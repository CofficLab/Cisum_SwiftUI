import Foundation
import OSLog

class FilePresenter: NSObject, NSFilePresenter {
    let fileURL: URL
    var presentedItemOperationQueue: OperationQueue = .main
    var onDidChange: () -> Void = { os_log("🍋 FilePresenter::changed") }

    init(fileURL: URL) {
        self.fileURL = fileURL
        super.init()
        // 注册，监视指定 URL
        NSFileCoordinator.addFilePresenter(self)
    }

    deinit {
        // 注销监视
        NSFileCoordinator.removeFilePresenter(self)
    }

    var presentedItemURL: URL? {
        return fileURL
    }

    func presentedItemDidChange() {
        // 当文件发生变化时，执行相关操作
        // 例如，重新加载文件或通知其他组件
        self.onDidChange()
    }
}
