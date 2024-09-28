import Foundation
import OSLog

actor iCloudHandler {
    static var label = "☁️ iCloudHandler::"
    let coordinator = NSFileCoordinator()
    var filePresenters: [URL: FilePresenter] = [:]
    var label: String { "\(Logger.isMain)\(Self.label)" }

    func write(targetURL: URL, data: Data) throws {
        var coordinationError: NSError?
        var writeError: Error?

        // 使用 coordinationError 变量来捕获 coordinate 方法的错误信息。
        // 如果不提供一个 NSError 指针，协调过程中发生的错误将无法被捕获和处理。
        coordinator.coordinate(writingItemAt: targetURL, options: [.forDeleting], error: &coordinationError) { url in
            do {
                try data.write(to: url, options: .atomic)
            } catch {
                writeError = error
            }
        }

        // 在闭包外部检查是否有错误发生
        if let error = writeError {
            throw error
        }

        // 检查协调过程中是否发生了错误
        if let coordinationError = coordinationError {
            throw coordinationError
        }
    }

    func read(url: URL) throws -> Data {
        var coordinationError: NSError?
        var readData: Data?
        var readError: Error?

        coordinator.coordinate(readingItemAt: url, options: [], error: &coordinationError) { url in
            do {
                readData = try Data(contentsOf: url)
            } catch {
                readError = error
            }
        }

        // 检查读取过程中是否发生了错误
        if let error = readError {
            throw error
        }

        // 检查协调过程中是否发生了错误
        if let coordinationError = coordinationError {
            throw coordinationError
        }

        // 确保读取到的数据不为空
        guard let data = readData else {
            throw NSError(domain: "CloudDocumentsHandlerError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data was read from the file."])
        }

        return data
    }

    func startMonitoringFile(at url: URL, onDidChange: (() -> Void)? = nil) {
        let defaultOnDidChange: () -> Void = {
            os_log("🍋 CloudDocumentsHelper::onDidChange")
        }
        let presenter = FilePresenter(fileURL: url)
        presenter.onDidChange = onDidChange ?? defaultOnDidChange
        filePresenters[url] = presenter
    }

    func stopMonitoringFile(at url: URL) {
        if let presenter = filePresenters[url] {
            NSFileCoordinator.removeFilePresenter(presenter)
        }
        filePresenters[url] = nil
    }
}

extension iCloudHandler {
    func download(url: URL) throws {
        let verbose = false
        if verbose {
            os_log("下载 \(url.lastPathComponent)")
        }
        var coordinationError: NSError?
        var downloadError: Error?
        
        if !iCloudHelper.isCloudPath(url: url) {
            os_log(.error, "\(url.lastPathComponent) 不是一个 iCloud文件")
            return
        }

        coordinator.coordinate(writingItemAt: url, options: [], error: &coordinationError) { newURL in
            do {
                try FileManager.default.startDownloadingUbiquitousItem(at: newURL)
            } catch {
                downloadError = error
            }
        }

        // 检查下载过程中是否发生了错误
        if let error = downloadError {
            throw error
        }

        // 检查协调过程中是否发生了错误
        if let coordinationError = coordinationError {
            throw coordinationError
        }
    }

    func evict(url: URL) throws {
        do {
            try FileManager.default.evictUbiquitousItem(at: url)
        } catch {
            throw error
        }
    }

    func moveFile(at sourceURL: URL, to destinationURL: URL) throws {
        var coordinationError: NSError?
        var moveError: Error?

        coordinator.coordinate(writingItemAt: sourceURL, options: .forMoving, writingItemAt: destinationURL, options: .forReplacing, error: &coordinationError) { newSourceURL, newDestinationURL in
            do {
                try FileManager.default.moveItem(at: newSourceURL, to: newDestinationURL)
            } catch {
                moveError = error
            }
        }

        // 检查移动过程中是否发生了错误
        if let error = moveError {
            throw error
        }

        // 检查协调过程中是否发生了错误
        if let coordinationError = coordinationError {
            throw coordinationError
        }
    }
}
