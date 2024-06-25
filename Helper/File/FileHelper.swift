import CryptoKit
import Foundation
import OSLog

#if os(macOS)
    import AppKit
#endif

#if os(iOS)
    import UIKit
#endif

class FileHelper {
    static var fileManager = FileManager.default
    static var label = "📃 FileHelper::"

    static func showInFinder(url: URL) {
        #if os(macOS)
            NSWorkspace.shared.activateFileViewerSelecting([url])
        #endif
    }

    static func openFolder(url: URL) {
        #if os(macOS)
        guard let dir = url else {
          // 显示错误提示
          let errorAlert = NSAlert()
          errorAlert.messageText = "打开目录出错"
          errorAlert.informativeText = "目录不存在"
          errorAlert.alertStyle = .critical
          errorAlert.addButton(withTitle: "好的")
          errorAlert.runModal()

          return
        }

        NSWorkspace.shared.open(dir)
        #endif
        
        #if os(iOS)
            // 检查 Files 应用程序是否可用
            if UIApplication.shared.canOpenURL(url) {
                // 打开 URL 并在 Files 应用程序中处理
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // 如果 Files 应用程序不可用,可以显示一个错误提示或采取其他措施
                print("无法打开文件")
            }
        #endif
    }

    static func isAudioFile(url: URL) -> Bool {
        return ["mp3", "wav", "m4a"].contains(url.pathExtension.lowercased())
    }

    static func isAudioiCloudFile(url: URL) -> Bool {
        let ex = url.pathExtension.lowercased()

        os_log("\(Logger.isMain)🔧 FileHelper::isAudioiCloudFile -> \(ex)")

        return ex == "icloud" && isAudioFile(url: url.deletingPathExtension())
    }
}

// MARK: Size

extension FileHelper {
    static func getSize(url: URL) -> Int {
        let resourceValues = try? url.resourceValues(forKeys: [.fileSizeKey])
        let size = resourceValues?.fileSize ?? 0
        os_log("File size: \(size) bytes")

        return size
    }

    static func getFileSize(_ url: URL, verbose: Bool = false) -> Int64 {
        do {
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            if let fileSize = attributes[.size] as? Int64 {
                return fileSize
            } else {
                os_log("Failed to retrieve file size.")
                return 0
            }
        } catch {
            if verbose {
                os_log(.error, "\(Self.label)::GetFileSize \(error.localizedDescription)")
                os_log(.error, "    \(url.path)")
            }
            
            return 0
        }
    }

    static func getFileSizeReadable(_ url: URL) -> String {
        let byteCountFormatter: ByteCountFormatter = {
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useMB, .useGB, .useTB]
            formatter.countStyle = .file
            return formatter
        }()

        if !fileManager.fileExists(atPath: url.path) {
            return "-"
        }

        do {
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            if let fileSize = attributes[.size] as? Int64 {
                return byteCountFormatter.string(fromByteCount: fileSize)
            } else {
                os_log("Failed to retrieve file size.")
                return "-"
            }
        } catch {
            os_log("Error: \(error.localizedDescription)")
            return "-"
        }
    }

    static func getFileSizeReadable(_ size: Int64) -> String {
        let byteCountFormatter: ByteCountFormatter = {
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useMB, .useGB, .useTB]
            formatter.countStyle = .file
            return formatter
        }()

        return byteCountFormatter.string(fromByteCount: size)
    }
}

// MARK: ContentType

extension FileHelper {
    static func isAudioFile(_ contentType: String) -> Bool {
        [
            "public.mp3",
            "com.microsoft.waveform-audio",
        ].contains(contentType)
    }
}

// MARK: Hash

extension FileHelper {
    static func getHash(_ url: URL) -> String {
        var fileHash = ""

        // 如果文件尚未下载，会卡住，直到下载完成
        do {
            let fileData = try Data(contentsOf: url)
            let hash = SHA256.hash(data: fileData)
            fileHash = hash.compactMap { String(format: "%02x", $0) }.joined()
        } catch {
            os_log("Error calculating file hash: \(error)")
        }

        return fileHash
    }

    static func getMD5(_ url: URL) -> String {
        if isDirectory(at: url) {
            return ""
        }
        
        do {
            let bufferSize = 1024
            var hash = Insecure.MD5()
            let fileHandle = try FileHandle(forReadingFrom: url)
            defer { fileHandle.closeFile() }

            while autoreleasepool(invoking: {
                let data = fileHandle.readData(ofLength: bufferSize)
                hash.update(data: data)
                return data.count > 0
            }) {}

            return hash.finalize().map { String(format: "%02hhx", $0) }.joined()
        } catch {
            os_log(.error, "计算MD5出错 -> \(error.localizedDescription)")
            print(error)
            return ""
        }
    }
    
    static func isDirectory(at url: URL) -> Bool {
        do {
            return try url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true
        } catch {
            return false
        }
    }
}
