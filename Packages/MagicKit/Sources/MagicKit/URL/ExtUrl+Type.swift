import Foundation
import SwiftUI

import UniformTypeIdentifiers

public extension URL {
    /// 返回 URL 对应的默认系统图标图片
    var defaultImage: Image {
        Image(systemName: systemIcon)
    }
    
    /// 是否是音频文件
    var isAudio: Bool {
        if let type = try? resourceValues(forKeys: [.contentTypeKey]).contentType {
            return type.conforms(to: .audio)
        }
        return audioExtensions.contains(pathExtension.lowercased())
    }

    /// 是否是视频文件
    var isVideo: Bool {
        if let type = try? resourceValues(forKeys: [.contentTypeKey]).contentType {
            // 检查是否是音频视觉内容，但排除纯音频内容
            return type.conforms(to: .audiovisualContent) && !type.conforms(to: .audio)
        }
        return videoExtensions.contains(pathExtension.lowercased())
    }

    /// 是否是图片文件
    var isImage: Bool {
        if let type = try? resourceValues(forKeys: [.contentTypeKey]).contentType {
            return type.conforms(to: .image)
        }
        return imageExtensions.contains(pathExtension.lowercased())
    }
    
    /// 是否是文档文件
    var isDocument: Bool {
        if let type = try? resourceValues(forKeys: [.contentTypeKey]).contentType {
            return type.conforms(to: .data)
        }
        return documentExtensions.contains(pathExtension.lowercased())
    }
    
    /// 是否是电子书
    var isEbook: Bool {
        if let type = try? resourceValues(forKeys: [.contentTypeKey]).contentType {
            return type.conforms(to: .epub) || type.conforms(to: .pdf)
        }
        return ebookExtensions.contains(pathExtension.lowercased())
    }
    
    /// 是否是字体文件
    var isFont: Bool {
        if let type = try? resourceValues(forKeys: [.contentTypeKey]).contentType {
            return type.conforms(to: .font)
        }
        return fontExtensions.contains(pathExtension.lowercased())
    }
    
    /// 是否是代码文件
    var isCode: Bool {
        codeExtensions.contains(pathExtension.lowercased())
    }

    /// 是否是文件夹
    var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }

    /// 是否是媒体文件（音频或视频）
    var isMedia: Bool {
        isAudio || isVideo
    }

    /// 是否是本地文件
    var isLocalFile: Bool {
        isFileURL && FileManager.default.fileExists(atPath: path)
    }

    /// 是否是网络 URL
    var isNetworkURL: Bool {
        scheme == "http" || scheme == "https"
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
        return textExtensions.contains(pathExtension.lowercased())
    }
    
    /// 是否是压缩文件
    var isArchive: Bool {
        if let type = try? resourceValues(forKeys: [.contentTypeKey]).contentType {
            return type.conforms(to: .archive)
        }
        return archiveExtensions.contains(pathExtension.lowercased())
    }

    /// 返回 URL 对应的文件类型标签视图
    var label: Label<Text, Image> {
        if isAudio {
            return Label("Audio", systemImage: icon)
        } else if isVideo {
            return Label("Video", systemImage: icon)
        } else if isImage {
            return Label("Image", systemImage: icon)
        } else if isDirectory {
            return Label("Directory", systemImage: icon)
        } else if isPDF {
            return Label("PDF", systemImage: icon)
        } else if isText {
            return Label("Text", systemImage: icon)
        } else if isArchive {
            return Label("Archive", systemImage: icon)
        } else if isDocument {
            return Label("Document", systemImage: icon)
        } else if isEbook {
            return Label("Ebook", systemImage: icon)
        } else if isFont {
            return Label("Font", systemImage: icon)
        } else if isCode {
            return Label("Code", systemImage: icon)
        } else {
            return Label("Other", systemImage: icon)
        }
    }

    /// 返回 URL 对应的文件类型图标名称
    var icon: String {
        if isAudio {
            return "music.note"
        } else if isVideo {
            return "film"
        } else if isImage {
            return "photo"
        } else if isDirectory {
            return "folder"
        } else if isPDF {
            return "doc.text"
        } else if isText {
            return "doc.text.fill"
        } else if isArchive {
            return "doc.zipper"
        } else if isDocument {
            return "doc.richtext"
        } else if isEbook {
            return "book"
        } else if isFont {
            return "textformat"
        } else if isCode {
            return "chevron.left.forwardslash.chevron.right"
        } else if isNetworkURL {
            return "globe"
        } else {
            return "doc"
        }
    }
    
    var systemIcon: String { icon }

    /// 基于文件扩展名快速获取图标名称（不调用 resourceValues，避免主线程卡顿）
    /// 适用于列表滚动等需要高性能的场景
    var fastIcon: String {
        let ext = pathExtension.lowercased()

        // 使用静态集合避免重复创建
        if Self.audioExtSet.contains(ext) {
            return "music.note"
        } else if Self.videoExtSet.contains(ext) {
            return "film"
        } else if Self.imageExtSet.contains(ext) {
            return "photo"
        } else if hasDirectoryPath {
            return "folder"
        } else {
            return "doc"
        }
    }

    /// 基于文件扩展名快速获取默认图片（不调用 resourceValues）
    var fastDefaultImage: Image {
        Image(systemName: fastIcon)
    }

    // 静态扩展名集合，避免重复创建
    private static let audioExtSet: Set<String> = [
        "mp3", "m4a", "aac", "wav", "aiff", "wma",
        "ogg", "oga", "opus", "flac", "alac", "mid",
        "midi", "ac3", "dsf", "dff", "ape", "wv"
    ]

    private static let videoExtSet: Set<String> = [
        "mp4", "m4v", "mov", "avi", "wmv", "flv",
        "mkv", "webm", "3gp", "mpeg", "mpg", "ts",
        "mts", "m2ts", "vob", "ogv", "rm", "rmvb",
        "asf", "divx", "f4v"
    ]

    private static let imageExtSet: Set<String> = [
        "jpg", "jpeg", "png", "gif", "bmp", "tiff",
        "webp", "heic", "heif", "raw", "svg", "ico",
        "tga", "psd", "ai", "eps", "cr2", "nef",
        "arw", "dng", "orf", "rw2"
    ]
}

// MARK: - Supported Extensions

private extension URL {
    /// 支持的音频文件扩展名
    var audioExtensions: Set<String> {
        [
            "mp3", "m4a", "aac", "wav", "aiff", "wma",
            "ogg", "oga", "opus", "flac", "alac", "mid",
            "midi", "ac3", "dsf", "dff", "ape", "wv"
        ]
    }

    /// 支持的视频文件扩展名
    var videoExtensions: Set<String> {
        [
            "mp4", "m4v", "mov", "avi", "wmv", "flv",
            "mkv", "webm", "3gp", "mpeg", "mpg", "ts",
            "mts", "m2ts", "vob", "ogv", "rm", "rmvb",
            "asf", "divx", "f4v"
        ]
    }

    /// 支持的图片文件扩展名
    var imageExtensions: Set<String> {
        [
            "jpg", "jpeg", "png", "gif", "bmp", "tiff",
            "webp", "heic", "heif", "raw", "svg", "ico",
            "tga", "psd", "ai", "eps", "cr2", "nef",
            "arw", "dng", "orf", "rw2"
        ]
    }

    /// 支持的文本文件扩展名
    var textExtensions: Set<String> {
        [
            "txt", "rtf", "md", "json", "xml", "yml",
            "yaml", "csv", "log", "ini", "conf", "cfg",
            "properties", "env", "toml", "tex"
        ]
    }
    
    /// 支持的压缩文件扩展名
    var archiveExtensions: Set<String> {
        [
            "zip", "rar", "7z", "tar", "gz", "bz2",
            "xz", "tgz", "tbz", "lz", "lzma", "lzo",
            "z", "ace", "cab", "iso", "dmg"
        ]
    }
    
    /// 支持的文档文件扩展名
    var documentExtensions: Set<String> {
        [
            "doc", "docx", "xls", "xlsx", "ppt", "pptx",
            "odt", "ods", "odp", "pages", "numbers",
            "keynote", "key", "wpd", "wps", "rtfd"
        ]
    }
    
    /// 支持的电子书扩展名
    var ebookExtensions: Set<String> {
        [
            "epub", "mobi", "azw", "azw3", "fb2",
            "lit", "lrf", "pdb", "pdf", "djvu",
            "cbz", "cbr", "cbt", "cb7"
        ]
    }
    
    /// 支持的字体文件扩展名
    var fontExtensions: Set<String> {
        [
            "ttf", "otf", "woff", "woff2", "eot",
            "pfm", "pfb", "sfd", "bdf", "psf"
        ]
    }
    
    /// 支持的代码文件扩展名
    var codeExtensions: Set<String> {
        [
            "swift", "java", "kt", "cpp", "c", "h",
            "hpp", "cs", "py", "rb", "php", "js",
            "ts", "html", "css", "scss", "less",
            "sql", "go", "rs", "dart", "lua"
        ]
    }
}

// MARK: - Preview

#if DEBUG
#Preview("File Types") {
    FileTypePreviewContainer()
}
#endif 
