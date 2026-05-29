import CryptoKit
import Foundation
import OSLog
import SwiftUI
#if os(iOS)
    import UIKit
#endif
#if os(macOS)
    import AppKit
#endif

/// URL 类型的扩展，提供常用的工具方法
extension URL: SuperLog {
    public nonisolated static let emoji = "🌉"
}

/// URL 类型的扩展，提供文件操作和路径处理功能
public extension URL {
    /// 统计当前 URL 下的文件数量（包含所有子孙文件夹）
    ///
    /// - Note: 会跳过隐藏文件与隐藏文件夹（以系统属性识别）。
    /// - Returns: 文件总数；若路径不存在则为 0
    func filesCountRecursively() -> Int {
        let fm = FileManager.default
        var isDirectory: ObjCBool = false
        guard fm.fileExists(atPath: self.path, isDirectory: &isDirectory) else { return 0 }

        // 若是文件，直接返回 1
        if isDirectory.boolValue == false {
            return 1
        }

        // 若是目录，递归统计所有非目录条目
        let keys: [URLResourceKey] = [.isDirectoryKey, .isRegularFileKey, .isSymbolicLinkKey]
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]
        guard let enumerator = fm.enumerator(
            at: self,
            includingPropertiesForKeys: keys,
            options: options
        ) else { return 0 }

        var count = 0
        for case let itemURL as URL in enumerator {
            do {
                let values = try itemURL.resourceValues(forKeys: Set(keys))
                // 仅统计常规文件与符号链接（不计目录本身）
                if values.isDirectory == true { continue }
                if values.isRegularFile == true || values.isSymbolicLink == true {
                    count += 1
                }
            } catch {
                // 读取属性失败时跳过该条目
                continue
            }
        }
        return count
    }

    /// 计算文件的 MD5 哈希值
    ///
    /// 用于获取文件的唯一标识或验证文件完整性
    /// ```swift
    /// let fileURL = URL(fileURLWithPath: "/path/to/file.txt")
    /// let hash = fileURL.getHash() // "d41d8cd98f00b204e9800998ecf8427e"
    /// ```
    /// - Parameter verbose: 是否打印详细日志，默认为 false
    /// - Returns: 文件的 MD5 哈希值字符串，如果是文件夹或计算失败则返回空字符串
    func getHash(verbose: Bool = false) -> String {
        if self.isFolder {
            return ""
        }

        do {
            let bufferSize = 1024
            var hash = Insecure.MD5()
            let fileHandle = try FileHandle(forReadingFrom: self)
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

    /// 获取文件内容的 Base64 编码或文本内容
    ///
    /// 如果是图片文件，返回 Base64 编码；如果是文本文件，返回文本内容
    /// ```swift
    /// let imageURL = URL(fileURLWithPath: "/path/to/image.jpg")
    /// let base64 = try imageURL.getBlob() // "data:image/jpeg;base64,..."
    /// ```
    /// - Returns: 文件内容的 Base64 编码或文本内容
    /// - Throws: 读取文件失败时抛出错误
    func getBlob() throws -> String {
        if self.isImage {
            do {
                let data = try Data(contentsOf: self)
                return data.base64EncodedString()
            } catch {
                os_log(.error, "读取文件失败: \(error)")
                return ""
            }
        } else {
            return try self.getContent()
        }
    }

    /// 读取文件文本内容
    ///
    /// ```swift
    /// let fileURL = URL(fileURLWithPath: "/path/to/file.txt")
    /// let content = try fileURL.getContent() // "文件内容..."
    /// ```
    /// - Returns: 文件的文本内容
    /// - Throws: 读取文件失败时抛出错误
    func getContent() throws -> String {
        do {
            return try String(contentsOfFile: self.path, encoding: .utf8)
        } catch {
            os_log(.error, "读取文件时发生错误: \(error)")
            throw error
        }
    }

    /// 获取父目录路径
    ///
    /// ```swift
    /// let fileURL = URL(fileURLWithPath: "/path/to/file.txt")
    /// let parent = fileURL.getParent() // "/path/to"
    /// ```
    /// - Returns: 父目录的 URL
    func getParent() -> URL {
        self.deletingLastPathComponent()
    }

    /// 判断是否为文件夹
    var isFolder: Bool { self.hasDirectoryPath }

    /// 判断是否不是文件夹
    var isNotFolder: Bool { !isFolder }

    /// 获取文件或文件夹名称
    var name: String { self.lastPathComponent }

    /// 判断是否为图片文件
    var isImage: Bool {
        if let type = try? resourceValues(forKeys: [.contentTypeKey]).contentType {
            return type.conforms(to: .image)
        }
        return ["jpg", "jpeg", "png", "gif", "bmp", "webp", "tiff", "svg", "ico", "heic", "heif",
                "raw", "tga", "psd", "ai", "eps", "cr2", "nef", "arw", "dng", "orf", "rw2"]
            .contains(pathExtension.lowercased())
    }
    
    /// 是否是音频文件
    var isAudio: Bool {
        if let type = try? resourceValues(forKeys: [.contentTypeKey]).contentType {
            return type.conforms(to: .audio)
        }
        return ["mp3", "m4a", "aac", "wav", "aiff", "wma", "ogg", "oga", "opus", "flac", "alac",
                "mid", "midi", "ac3", "dsf", "dff", "ape", "wv"]
            .contains(pathExtension.lowercased())
    }
    
    /// 是否是视频文件
    var isVideo: Bool {
        if let type = try? resourceValues(forKeys: [.contentTypeKey]).contentType {
            return type.conforms(to: .audiovisualContent) && !type.conforms(to: .audio)
        }
        return ["mp4", "m4v", "mov", "avi", "wmv", "flv", "mkv", "webm", "3gp", "mpeg", "mpg",
                "ts", "mts", "m2ts", "vob", "ogv", "rm", "rmvb", "asf", "divx", "f4v"]
            .contains(pathExtension.lowercased())
    }
    
    /// 是否是文档文件
    var isDocument: Bool {
        if let type = try? resourceValues(forKeys: [.contentTypeKey]).contentType {
            return type.conforms(to: .data)
        }
        return ["doc", "docx", "xls", "xlsx", "ppt", "pptx", "odt", "ods", "odp", "pages",
                "numbers", "keynote", "key", "wpd", "wps", "rtfd"]
            .contains(pathExtension.lowercased())
    }
    
    /// 是否是 PDF 文件
    var isPDF: Bool {
        if let type = try? resourceValues(forKeys: [.contentTypeKey]).contentType {
            return type.conforms(to: .pdf)
        }
        return pathExtension.lowercased() == "pdf"
    }
    
    /// 是否是文本文件
    var isText: Bool {
        if let type = try? resourceValues(forKeys: [.contentTypeKey]).contentType {
            return type.conforms(to: .text)
        }
        return ["txt", "rtf", "md", "json", "xml", "yml", "yaml", "csv", "log", "ini", "conf",
                "cfg", "properties", "env", "toml", "tex"]
            .contains(pathExtension.lowercased())
    }
    
    /// 是否是压缩文件
    var isArchive: Bool {
        if let type = try? resourceValues(forKeys: [.contentTypeKey]).contentType {
            return type.conforms(to: .archive)
        }
        return ["zip", "rar", "7z", "tar", "gz", "bz2", "xz", "tgz", "tbz", "lz", "lzma",
                "lzo", "z", "ace", "cab", "iso", "dmg"]
            .contains(pathExtension.lowercased())
    }
    
    /// 是否是代码文件
    var isCode: Bool {
        ["swift", "java", "kt", "cpp", "c", "h", "hpp", "cs", "py", "rb", "php", "js",
         "ts", "html", "css", "scss", "less", "sql", "go", "rs", "dart", "lua"]
            .contains(pathExtension.lowercased())
    }
    
    /// 是否是目录（使用 resourceValues 检查）
    var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
    
    /// 是否是媒体文件（音频或视频）
    var isMedia: Bool { isAudio || isVideo }
    
    /// 是否是本地文件
    var isLocalFile: Bool {
        isFileURL && FileManager.default.fileExists(atPath: path)
    }
    
    /// 是否是网络 URL
    var isNetworkURL: Bool {
        scheme == "http" || scheme == "https"
    }
    
    /// 返回 URL 对应的文件类型图标名称
    var icon: String {
        if isAudio { return "music.note" }
        else if isVideo { return "film" }
        else if isImage { return "photo" }
        else if isDirectory { return "folder" }
        else if isPDF { return "doc.text" }
        else if isText { return "doc.text.fill" }
        else if isArchive { return "doc.zipper" }
        else if isDocument { return "doc.richtext" }
        else if isCode { return "chevron.left.forwardslash.chevron.right" }
        else if isNetworkURL { return "globe" }
        else { return "doc" }
    }
    
    /// 基于文件扩展名快速获取图标名称（不调用 resourceValues，避免主线程卡顿）
    var fastIcon: String {
        let ext = pathExtension.lowercased()
        let audioSet: Set<String> = ["mp3", "m4a", "aac", "wav", "aiff", "wma", "ogg", "oga", "opus", "flac", "alac", "mid", "midi", "ac3", "dsf", "dff", "ape", "wv"]
        let videoSet: Set<String> = ["mp4", "m4v", "mov", "avi", "wmv", "flv", "mkv", "webm", "3gp", "mpeg", "mpg", "ts", "mts", "m2ts", "vob", "ogv", "rm", "rmvb", "asf", "divx", "f4v"]
        let imageSet: Set<String> = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "webp", "heic", "heif", "raw", "svg", "ico", "tga", "psd", "ai", "eps", "cr2", "nef", "arw", "dng", "orf", "rw2"]
        
        if audioSet.contains(ext) { return "music.note" }
        else if videoSet.contains(ext) { return "film" }
        else if imageSet.contains(ext) { return "photo" }
        else if hasDirectoryPath { return "folder" }
        else { return "doc" }
    }
    
    var systemIcon: String { icon }
    
    /// 基于文件扩展名快速获取默认图片（不调用 resourceValues）
    var fastDefaultImage: Image { Image(systemName: fastIcon) }
    
    /// 返回 URL 对应的默认系统图标图片
    var defaultImage: Image { Image(systemName: icon) }

    /// 获取下一个文件
    func getNextFile() -> URL? {
        let fm = FileManager.default
        let parent = self.deletingLastPathComponent()
        guard let contents = try? fm.contentsOfDirectory(at: parent, includingPropertiesForKeys: nil, options: []) else {
            return nil
        }
        let sorted = contents.sorted { $0.lastPathComponent < $1.lastPathComponent }
        guard let index = sorted.firstIndex(of: self) else { return nil }
        let nextIndex = index + 1
        guard nextIndex < sorted.count else { return nil }
        let nextURL = sorted[nextIndex]
        var isDir: ObjCBool = false
        fm.fileExists(atPath: nextURL.path, isDirectory: &isDir)
        if isDir.boolValue {
            return nil
        }
        return nextURL
    }

    /// 获取空设备路径
    static var null: URL {
        URL(filePath: "/dev/null")
    }

    /// 读取文件头部字节
    ///
    /// 用于判断文件类型
    /// ```swift
    /// let fileURL = URL(fileURLWithPath: "/path/to/image.jpg")
    /// let header = fileURL.readFileHeader(length: 3) // [0xFF, 0xD8, 0xFF]
    /// ```
    /// - Parameter length: 要读取的字节数
    /// - Returns: 文件头部字节数组，读取失败时返回 nil
    func readFileHeader(length: Int) -> [UInt8]? {
        do {
            let fileData = try Data(contentsOf: self, options: .mappedIfSafe)
            return Array(fileData.prefix(length))
        } catch {
            print("读取文件头时出错: \(error)")
            return nil
        }
    }

    /// 移除路径开头的斜杠
    ///
    /// ```swift
    /// let url = URL(string: "/path/to/file")!
    /// let path = url.removingLeadingSlashes() // "path/to/file"
    /// ```
    /// - Returns: 移除开头斜杠后的路径字符串
    func removingLeadingSlashes() -> String {
        return self.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    /// 获取简短标题
    var title: String { self.lastPathComponent.count <= 30 ? self.lastPathComponent : String(self.lastPathComponent.prefix(30)) + "..." }

    // MARK: - 文件类型判断

    /// 文件类型签名字典
    var imageSignatures: [String: [UInt8]] {
        [
            "jpg": [0xFF, 0xD8, 0xFF],
            "png": [0x89, 0x50, 0x4E, 0x47],
            "gif": [0x47, 0x49, 0x46],
            "bmp": [0x42, 0x4D],
            "webp": [0x52, 0x49, 0x46, 0x46],
        ]
    }

    /// 生成默认音频缩略图
    /// - Parameter size: 缩略图大小
    /// - Returns: 音频缩略图
    @ViewBuilder
    func defaultAudioThumbnail(size: CGSize) -> some View {
        Image(systemName: "music.note")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size.width, height: size.height)
    }

    /// 获取路径的最后三个组件
    ///
    /// 用于显示较长路径的简短版本
    /// ```swift
    /// let url = URL(string: "file:///path/to/folder/documents/report.pdf")!
    /// print(url.shortPath()) // "folder/documents/report.pdf"
    /// ```
    /// - Returns: 包含最后三个路径组件的字符串
    func shortPath() -> String {
        self.lastThreeComponents()
    }

    /// 获取路径的最后三个组件
    ///
    /// ```swift
    /// let url = URL(string: "file:///path/to/folder/a/b/c.png")!
    /// print(url.lastThreeComponents()) // "a/b/c.png"
    /// ```
    /// - Returns: 最后三个路径组件组成的字符串
    func lastThreeComponents() -> String {
        let components = self.pathComponents.filter { $0 != "/" }
        let lastThree = components.suffix(3)
        return lastThree.joined(separator: "/")
    }

    /// 添加文件夹到路径末尾
    ///
    /// ```swift
    /// let url = URL(string: "file:///path/to")!
    /// let newUrl = url.appendingFolder("documents")
    /// // 结果: "file:///path/to/documents"
    /// ```
    /// - Parameter folderName: 要添加的文件夹名称
    /// - Returns: 添加文件夹后的新 URL
    func appendingFolder(_ folderName: String) -> URL {
        let cleanFolderName = folderName.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return self.appendingPathComponent(cleanFolderName, isDirectory: true)
    }

    /// 添加文件到路径末尾
    ///
    /// ```swift
    /// let url = URL(string: "file:///path/to")!
    /// let newUrl = url.appendingFile("document.txt")
    /// // 结果: "file:///path/to/document.txt"
    /// ```
    /// - Parameter fileName: 要添加的文件名
    /// - Returns: 添加文件后的新 URL
    func appendingFile(_ fileName: String) -> URL {
        let cleanFileName = fileName.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return self.appendingPathComponent(cleanFileName, isDirectory: false)
    }

    /// 打开系统目录选择器，让用户选择一个目录
    ///
    /// ```swift
    /// do {
    ///     let fileUrl = try URL.selectDirectory.appendingPathComponent("example.txt")
    ///     // 使用选中的目录...
    /// } catch {
    ///     // 处理错误...
    /// }
    /// ```
    /// - Returns: 用户选择的目录 URL
    /// - Throws: 如果用户取消选择，抛出 URLError.userCancelledAuthentication
    static var selectDirectory: URL {
        get throws {
            #if os(macOS)
                let panel = NSOpenPanel()
                panel.canChooseFiles = false
                panel.canChooseDirectories = true
                panel.allowsMultipleSelection = false
                panel.canCreateDirectories = true
                panel.prompt = "选择保存目录"

                guard panel.runModal() == .OK,
                      let directoryUrl = panel.url else {
                    throw URLError(.userCancelledAuthentication)
                }

                return directoryUrl
            #else
                throw URLError(.unsupportedURL)
            #endif
        }
    }
    
    /// 在 Finder/文件管理器 中打开当前路径
    func open() {
        #if os(macOS)
            NSWorkspace.shared.open(self)
        #elseif os(iOS)
            // iOS 上不支持直接打开文件管理器
        #endif
    }
    
    /// 获取最近的文件夹路径
    ///
    /// 如果当前路径是文件夹，返回自身；如果是文件，返回父目录
    func nearestFolder() -> URL {
        self.isFolder ? self : self.deletingLastPathComponent()
    }
    
    /// 获取文件大小的可读格式
    ///
    /// ```swift
    /// let fileURL = URL(fileURLWithPath: "/path/to/largefile.zip")
    /// print(fileURL.getSizeReadable()) // "1.5 GB"
    /// ```
    /// - Returns: 文件大小的可读字符串，如果是文件夹或获取失败则返回 "0 bytes"
    func getSizeReadable() -> String {
        let fm = FileManager.default
        guard let attrs = try? fm.attributesOfItem(atPath: self.path),
              let size = attrs[.size] as? UInt64 else {
            return "0 bytes"
        }
        
        if size < 1024 {
            return "\(size) bytes"
        } else if size < 1024 * 1024 {
            return String(format: "%.1f KB", Double(size) / 1024.0)
        } else if size < 1024 * 1024 * 1024 {
            return String(format: "%.1f MB", Double(size) / (1024.0 * 1024.0))
        } else {
            return String(format: "%.1f GB", Double(size) / (1024.0 * 1024.0 * 1024.0))
        }
    }
    
    /// 创建打开按钮
    ///
    /// 用于在 Finder 中打开该路径
    func makeOpenButton() -> some View {
        Button(action: {
            self.open()
        }) {
            Image(systemName: "folder")
        }
        .buttonStyle(.plain)
    }
    
    /// 检查 URL 是否位于 iCloud 中
    ///
    /// - Parameter verbose: 是否打印详细日志
    /// - Returns: 是否在 iCloud 中
    func checkIsICloud(verbose: Bool = false) -> Bool {
        let fm = FileManager.default
        // 获取 iCloud 容器 URL
        guard let iCloudURL = fm.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") else {
            return false
        }
        return self.path.hasPrefix(iCloudURL.path)
    }
    
    /// 检查文件是否已下载
    ///
    /// 对于 iCloud 文件，检查是否已下载到本地
    var isNotDownloaded: Bool {
        #if os(macOS)
        do {
            let resourceValues = try self.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
            if let status = resourceValues.ubiquitousItemDownloadingStatus {
                return status == .notDownloaded
            }
            return false
        } catch {
            return false
        }
        #else
        return false
        #endif
    }
    
    /// 检查文件是否已下载
    ///
    /// 对于 iCloud 文件，检查是否已下载到本地
    var isDownloaded: Bool {
        #if os(macOS)
        do {
            let resourceValues = try self.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
            if let status = resourceValues.ubiquitousItemDownloadingStatus {
                return status == .current
            }
            return true // 非 iCloud 文件视为已下载
        } catch {
            return true // 出错时默认视为已下载
        }
        #else
        return true
        #endif
    }
    
    /// 将文件夹展开为所有文件的列表
    ///
    /// - Returns: 所有文件的 URL 数组
    func flatten() -> [URL] {
        let fm = FileManager.default
        guard self.isFolder else { return [self] }
        
        var files: [URL] = []
        if let enumerator = fm.enumerator(at: self, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]) {
            for case let url as URL in enumerator {
                if !url.isFolder {
                    files.append(url)
                }
            }
        }
        return files
    }
    
    /// 获取文件夹内的直接子项
    ///
    /// - Returns: 直接子项的 URL 数组
    func getChildren() -> [URL] {
        let fm = FileManager.default
        guard self.isFolder else { return [] }
        
        do {
            return try fm.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        } catch {
            return []
        }
    }
    
    // MARK: - 文件操作
    
    /// 删除指定 URL 对应的文件或目录
    func delete() throws {
        guard FileManager.default.fileExists(atPath: self.path) else {
            return
        }
        try FileManager.default.removeItem(at: self)
    }
    
    /// 递归返回目录及其子目录中的所有文件
    func getAllFilesInDirectory() -> [URL] {
        let fm = FileManager.default
        var fileURLs: [URL] = []
        do {
            let urls = try fm.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [])
            for url in urls {
                if url.hasDirectoryPath {
                    fileURLs += url.getAllFilesInDirectory()
                } else {
                    fileURLs.append(url)
                }
            }
        } catch {
            os_log(.error, "读取目录时发生错误: \(error.localizedDescription)")
        }
        return fileURLs.filter { $0.lastPathComponent != ".DS_Store" }
    }
    
    /// 返回当前目录的直接文件子项（不包括目录）
    func getFileChildren() -> [URL] {
        let fm = FileManager.default
        var fileURLs: [URL] = []
        do {
            let urls = try fm.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [])
            fileURLs = urls.filter { !$0.hasDirectoryPath }
        } catch {
            os_log(.error, "读取目录时发生错误: \(error)")
        }
        return fileURLs
            .filter { $0.lastPathComponent != ".DS_Store" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }
    
    /// 返回父目录中的上一个文件
    func getPrevFile() -> URL? {
        let parent = deletingLastPathComponent()
        let files = parent.getChildren()
        guard let index = files.firstIndex(of: self) else { return nil }
        return index > 0 ? files[index - 1] : nil
    }
    
    /// 计算文件或目录的大小（以字节为单位）
    func getSize() -> Int64 {
        var size: Int64 = 0
        if hasDirectoryPath {
            size = getAllFilesInDirectory()
                .reduce(Int64(0)) { $0 + $1.getSize() }
        } else {
            let attributes = try? resourceValues(forKeys: [.fileSizeKey])
            size = Int64(attributes?.fileSize ?? 0)
        }
        return size
    }
    
    /// 检查 URL 是否指向现有目录
    var isDirExist: Bool {
        var isDir: ObjCBool = true
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
    }
    
    /// 检查 URL 是否指向现有文件
    var isFileExist: Bool {
        FileManager.default.fileExists(atPath: path)
    }
    
    var isNotFileExist: Bool { !isFileExist }
    var isNotDirExist: Bool { !isDirExist }
    
    /// 如果 URL 对应的目录或文件不存在则创建它
    @discardableResult
    func createIfNotExist() throws -> URL {
        let parentDir = deletingLastPathComponent()
        if parentDir.isNotDirExist {
            try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)
        }
        
        if hasDirectoryPath {
            if isNotDirExist {
                try FileManager.default.createDirectory(at: self, withIntermediateDirectories: true)
            }
        } else {
            if isNotFileExist {
                try Data().write(to: self)
            }
        }
        
        return self
    }
    
    /// 删除当前文件或目录的父文件夹
    func removeParentFolder() throws {
        try FileManager.default.removeItem(at: deletingLastPathComponent())
    }
    
    /// 根据条件删除当前文件或目录的父文件夹
    func removeParentFolderWhen(_ condition: Bool) {
        if condition {
            try? removeParentFolder()
        }
    }
    
    #if os(macOS)
    /// 在 Finder 中显示
    func showInFinder() {
        NSWorkspace.shared.activateFileViewerSelecting([self])
    }
    #endif
    
    /// 打开文件所在文件夹
    func openFolder() {
        let folder = isFolder ? self : deletingLastPathComponent()
        #if os(macOS)
            NSWorkspace.shared.open(folder)
        #endif
    }
    
    /// 在 Finder 中打开（跨平台）
    func openInFinder() {
        #if os(macOS)
            showInFinder()
        #else
            openFolder()
        #endif
    }
    
    /// 在浏览器中打开 URL
    func openInBrowser() {
        #if os(iOS)
            UIApplication.shared.open(self)
        #elseif os(macOS)
            NSWorkspace.shared.open(self)
        #endif
    }
    
    // MARK: - iCloud 下载相关
    
    /// 获取文件的状态信息
    var magicFileStatus: String? {
        if isNetworkURL {
            return "远程文件"
        } else if isFileURL {
            if checkIsICloud(verbose: true) {
                if checkIsDownloading(verbose: false) {
                    return "正在从 iCloud 下载"
                } else if isDownloaded {
                    return "已从 iCloud 下载"
                } else {
                    return "未从 iCloud 下载"
                }
            }
            return isLocal ? "本地文件" : nil
        }
        return nil
    }
    
    /// 下载方式
    enum DownloadMethod {
        /// 轮询方式
        case polling(updateInterval: TimeInterval = 0.5)
        /// 使用 NSMetadataQuery
        case query
    }
    
    /// 下载 iCloud 文件
    func download(
        verbose: Bool = false,
        reason: String,
        method: DownloadMethod = .polling(),
        onProgress: ((Double) -> Void)? = nil
    ) async throws {
        guard checkIsICloud(verbose: false), isNotDownloaded else {
            if verbose {
                os_log("\(self.t)文件无需下载：不是 iCloud 文件或已下载完成")
            }
            return
        }

        if verbose {
            os_log("\(self.t)🛫 (\(reason)) <\(self.title)> 开始下载")
        }

        guard let onProgress = onProgress else {
            try await FileManager.default.startDownloadingUbiquitousItem(at: self)
            if verbose {
                os_log("\(self.t)⏬ (\(reason)) <\(self.title)> 已启动下载")
            }
            return
        }

        switch method {
        case let .polling(updateInterval):
            try await downloadWithPolling(verbose: verbose, updateInterval: updateInterval, onProgress: onProgress)
        case .query:
            try await downloadWithQuery(verbose: verbose, onProgress: onProgress)
        }
    }
    
    /// 检查文件是否已下载（带详细日志）
    func checkIsDownloaded(verbose: Bool = false) -> Bool {
        var mutableSelf = self
        mutableSelf.removeAllCachedResourceValues()

        guard let resources = try? mutableSelf.resourceValues(forKeys: [
            .isUbiquitousItemKey,
            .ubiquitousItemDownloadingStatusKey,
            URLResourceKey(rawValue: "NSURLUbiquitousItemPercentDownloadedKey"),
        ]) else {
            return true
        }

        guard resources.isUbiquitousItem == true else {
            return true
        }

        if let progress = resources.allValues[URLResourceKey(rawValue: "NSURLUbiquitousItemPercentDownloadedKey")] as? Double, progress >= 100.0 {
            return true
        }

        guard let status = resources.ubiquitousItemDownloadingStatus else {
            return false
        }

        return status == .current
    }
    
    /// 检查文件是否正在下载
    func checkIsDownloading(verbose: Bool = false) -> Bool {
        var mutableSelf = self
        mutableSelf.removeAllCachedResourceValues()
        
        guard let resources = try? mutableSelf.resourceValues(forKeys: [
            .isUbiquitousItemKey,
            .ubiquitousItemDownloadingStatusKey,
            .ubiquitousItemIsDownloadingKey,
        ]) else {
            return false
        }

        guard resources.isUbiquitousItem == true else {
            return false
        }

        if let isDownloading = resources.ubiquitousItemIsDownloading, isDownloading {
            return true
        }

        if let status = resources.ubiquitousItemDownloadingStatus {
            return status.rawValue == "NSMetadataUbiquitousItemDownloadingStatusDownloading"
        }

        return false
    }
    
    var isNotiCloud: Bool {
        !checkIsICloud(verbose: false)
    }

    var isLocal: Bool {
        isNotiCloud
    }
    
    /// 创建下载按钮
    func makeDownloadButton(
        size: CGFloat = 28,
        showLabel: Bool = false,
        destination: URL? = nil
    ) -> some View {
        DownloadButtonView(
            url: self,
            size: size,
            showLabel: showLabel,
            destination: destination
        )
    }
    
    /// 从本地驱动器中移除文件，但保留在 iCloud 中
    @discardableResult
    func evict() throws -> Bool {
        os_log("\(self.t)开始从本地移除文件: \(self.path)")

        guard checkIsICloud(verbose: false) else {
            os_log("\(self.t)不是 iCloud 文件，无法执行移除操作")
            return false
        }

        guard isDownloaded else {
            os_log("\(self.t)文件未下载，无需移除")
            return true
        }

        do {
            try FileManager.default.evictUbiquitousItem(at: self)
            os_log("\(self.t)文件已从本地成功移除")
            return true
        } catch {
            os_log("\(self.t)移除文件失败: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// 移动文件到目标位置，支持 iCloud 文件
    func moveTo(_ destination: URL) async throws {
        os_log("\(self.t)开始移动文件: \(self.path) -> \(destination.path)")

        if self.checkIsICloud(verbose: false) && self.isNotDownloaded {
            os_log("\(self.t)检测到 iCloud 文件未下载，开始下载")
            try await download(verbose: false, reason: "移动文件时，检测到 iCloud 文件未下载，开始下载")
        }

        let coordinator = NSFileCoordinator()
        var coordinationError: NSError?
        var moveError: Error?

        coordinator.coordinate(
            writingItemAt: self,
            options: .forMoving,
            writingItemAt: destination,
            options: .forReplacing,
            error: &coordinationError
        ) { sourceURL, destinationURL in
            do {
                os_log("\(self.t)执行文件移动操作")
                try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
                os_log("\(self.t)文件移动完成")
            } catch {
                moveError = error
                os_log("\(self.t)移动文件失败: \(error.localizedDescription)")
            }
        }

        if let error = moveError {
            throw error
        }

        if let error = coordinationError {
            throw error
        }
    }
    
    /// 获取文件的下载进度快照
    func getDownloadProgressSnapshot(verbose: Bool = false) -> Double {
        var mutableSelf = self
        mutableSelf.removeAllCachedResourceValues()

        if isLocal {
            return 1.0
        }

        if checkIsICloud(verbose: false) {
            let percentKey = URLResourceKey(rawValue: "NSURLUbiquitousItemPercentDownloadedKey")
            guard let resources = try? mutableSelf.resourceValues(forKeys: [
                .fileSizeKey,
                .fileAllocatedSizeKey,
                .ubiquitousItemDownloadingStatusKey,
                .ubiquitousItemIsDownloadingKey,
                percentKey,
            ]) else {
                return 0.0
            }
            
            if let status = resources.ubiquitousItemDownloadingStatus, status == .current {
                return 1.0
            }
            
            if let percent = resources.allValues[percentKey] as? Double, percent > 0 {
                return min(percent / 100.0, 1.0)
            }

            guard let totalSize = resources.fileSize, totalSize > 0,
                  let downloadedSize = resources.fileAllocatedSize else {
                return 0.0
            }

            return Double(downloadedSize) / Double(totalSize)
        }

        return 0.0
    }
    
    // MARK: - Private Download Helpers
    
    private func downloadWithPolling(
        verbose: Bool,
        updateInterval: TimeInterval,
        onProgress: @escaping (Double) -> Void
    ) async throws {
        try FileManager.default.startDownloadingUbiquitousItem(at: self)

        while checkIsDownloading(verbose: false) {
            if let resources = try? self.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey, .ubiquitousItemDownloadingErrorKey, .fileSizeKey, .fileAllocatedSizeKey]),
               let totalSize = resources.fileSize,
               let downloadedSize = resources.fileAllocatedSize {
                let progress = Double(downloadedSize) / Double(totalSize)
                onProgress(progress)

                if let error = resources.ubiquitousItemDownloadingError {
                    throw error
                }
            }

            try await Task.sleep(nanoseconds: UInt64(updateInterval * 1000000000))
        }
    }

    private func downloadWithQuery(
        verbose: Bool,
        onProgress: @escaping (Double) -> Void
    ) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let query = NSMetadataQuery()
            query.searchScopes = [NSMetadataQueryUbiquitousDataScope]
            query.predicate = NSPredicate(format: "%K == %@", NSMetadataItemURLKey, self.path)

            var observers: [NSObjectProtocol] = []

            let startObserver = NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidStartGathering,
                object: query,
                queue: .main
            ) { _ in
                do {
                    try FileManager.default.startDownloadingUbiquitousItem(at: self)
                } catch {
                    observers.forEach { NotificationCenter.default.removeObserver($0) }
                    continuation.resume(throwing: error)
                }
            }
            observers.append(startObserver)

            let updateObserver = NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidUpdate,
                object: query,
                queue: .main
            ) { _ in
                guard let item = query.results.first as? NSMetadataItem else { return }

                let downloadStatus = item.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as? String
                let isDownloading = downloadStatus == "NSMetadataUbiquitousItemDownloadingStatusDownloading"

                if isDownloading {
                    if let downloadedSize = item.value(forAttribute: "NSMetadataUbiquitousItemDownloadedSizeKey") as? NSNumber,
                       let totalSize = item.value(forAttribute: "NSMetadataUbiquitousItemTotalSizeKey") as? NSNumber {
                        let progress = Double(truncating: downloadedSize) / Double(truncating: totalSize)
                        onProgress(progress)
                    }

                    if let error = item.value(forAttribute: NSMetadataUbiquitousItemDownloadingErrorKey) as? Error {
                        observers.forEach { NotificationCenter.default.removeObserver($0) }
                        query.stop()
                        continuation.resume(throwing: error)
                    }
                } else if downloadStatus == "NSMetadataUbiquitousItemDownloadingStatusCurrent" {
                    observers.forEach { NotificationCenter.default.removeObserver($0) }
                    query.stop()
                    continuation.resume(returning: ())
                }
            }
            observers.append(updateObserver)

            let finishObserver = NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidFinishGathering,
                object: query,
                queue: .main
            ) { _ in }
            observers.append(finishObserver)

            query.start()
        }
    }
}
