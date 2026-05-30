import Foundation
import AVFoundation
import UniformTypeIdentifiers
import OSLog
import SwiftUI
import ID3TagEditor

/// 写入封面时可能出现的错误
public enum CoverWriteError: LocalizedError {
    case fileNotExists(path: String)
    case fileNotWritable(path: String)
    case exportSessionCreationFailed
    case exportFailed(Error?)
    case temporaryFileOperationFailed(Error)
    case mp3ProcessingFailed(Error?)
    case wavProcessingFailed(Error?)
    
    public var errorDescription: String? {
        switch self {
        case .fileNotExists(let path):
            return "文件不存在：\(path)"
        case .fileNotWritable(let path):
            return "文件不可写入：\(path)"
        case .exportSessionCreationFailed:
            return "创建导出会话失败"
        case .exportFailed(let error):
            if let error = error as NSError? {
                return """
                导出失败：
                - 错误描述：\(error.localizedDescription)
                - 错误域：\(error.domain)
                - 错误代码：\(error.code)
                - 详细信息：\(error.userInfo)
                """
            }
            return "导出失败：\(error?.localizedDescription ?? "未知错误")"
        case .temporaryFileOperationFailed(let error):
            return "临时文件操作失败：\(error.localizedDescription)"
        case .mp3ProcessingFailed(let error):
            return "MP3 文件处理失败：\(error?.localizedDescription ?? "未知错误")"
        case .wavProcessingFailed(let error):
            return "WAV 文件处理失败：\(error?.localizedDescription ?? "未知错误")"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .fileNotExists:
            return "请确认文件路径是否正确"
        case .fileNotWritable:
            return "请检查文件权限"
        case .exportSessionCreationFailed:
            return "可能是文件格式不支持或系统资源不足"
        case .exportFailed:
            return "可能是文件格式不兼容或磁盘空间不足"
        case .temporaryFileOperationFailed:
            return "可能是磁盘空间不足或权限问题"
        case .mp3ProcessingFailed:
            return "可能是 MP3 文件处理失败"
        case .wavProcessingFailed:
            return "可能是 WAV 文件处理失败"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .fileNotExists:
            return "请选择一个存在的音频文件"
        case .fileNotWritable:
            return "请确保应用有写入权限"
        case .exportSessionCreationFailed:
            return "请尝试使用其他音频格式或重启应用"
        case .exportFailed:
            return "请尝试将文件转换为 M4A 格式后再添加封面"
        case .temporaryFileOperationFailed:
            return "请确保磁盘有足够空间并检查权限设置"
        case .mp3ProcessingFailed:
            return "请检查 MP3 文件处理逻辑"
        case .wavProcessingFailed:
            return "请检查 WAV 文件处理逻辑"
        }
    }
}

extension URL {
    /// 将图片写入媒体文件作为封面
    public func writeCoverToMediaFile(
        imageData: Data,
        imageType: String = "image/jpeg",
        verbose: Bool = false
    ) async throws {
        if verbose {
            os_log("开始写入封面到文件: \(self.path)")
        }
        
        // 1. 检查文件是否存在且可写
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: self.path) else {
            throw CoverWriteError.fileNotExists(path: self.path)
        }
        
        guard fileManager.isWritableFile(atPath: self.path) else {
            throw CoverWriteError.fileNotWritable(path: self.path)
        }
        
        // 对于 MP3 文件，使用专门的处理方法
        if self.pathExtension.lowercased() == "mp3" {
            try await writeCoverToMP3File(imageData: imageData, verbose: verbose)
            return
        }
        
        // 对于 WAV 文件，使用专门的处理方法
        if self.pathExtension.lowercased() == "wav" {
            try await writeCoverToWAVFile(imageData: imageData, verbose: verbose)
            return
        }
        
        // 2. 创建临时文件路径，始终使用 .m4a 扩展名
        let temporaryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("m4a") // 强制使用 .m4a 扩展名
        
        // 3. 创建 AVAsset 和选择合适的预设
        let asset = AVURLAsset(url: self)
        let (exportPreset, outputFileType): (String, AVFileType) = {
            switch self.pathExtension.lowercased() {
            case "mp3":
                // MP3 文件我们需要使用 m4a 作为中间格式
                return (AVAssetExportPresetPassthrough, .m4a)
            case "m4a", "m4b", "m4r":
                // 对于 M4A 系列，使用无损复制
                return (AVAssetExportPresetPassthrough, .m4a)
            case "aif", "aiff":
                // 对于其他格式，使用高质量编码
                return (AVAssetExportPresetHighestQuality, .m4a)
            default:
                // 默认使用高质量编码
                return (AVAssetExportPresetHighestQuality, .m4a)
            }
        }()
        
        if verbose {
            let sourceSize = (try? FileManager.default.attributesOfItem(atPath: self.path)[.size] as? Int64) ?? 0
            os_log("""
            文件信息：
            - 源文件路径：\(self.path)
            - 源文件扩展名：\(self.pathExtension)
            - 临时文件路径：\(temporaryURL.path)
            - 导出预设：\(exportPreset)
            - 输出文件类型：\(outputFileType.rawValue)
            - 源文件大小：\(sourceSize) bytes
            """)
        }
        
        guard let exportSession = AVAssetExportSession(
            asset: asset,
            presetName: exportPreset
        ) else {
            throw CoverWriteError.exportSessionCreationFailed
        }
        
        // 4. 配置导出会话
        exportSession.outputFileType = outputFileType
        exportSession.outputURL = temporaryURL
        
        // 5. 加载现有元数据
        var metadata: [AVMetadataItem] = []
        do {
            metadata = try await asset.load(.metadata)
            // 移除现有的封面元数据
            metadata.removeAll { item in
                item.key as? String == AVMetadataKey.id3MetadataKeyAttachedPicture.rawValue ||
                item.key as? String == AVMetadataKey.iTunesMetadataKeyCoverArt.rawValue
            }
        } catch {
            if verbose {
                os_log("无法加载现有元数据，将创建新的元数据")
            }
        }
        
        // 6. 添加新的封面元数据
        let artworkItem = AVMutableMetadataItem()
        artworkItem.key = AVMetadataKey.iTunesMetadataKeyCoverArt.rawValue as NSString
        artworkItem.keySpace = .iTunes
        artworkItem.value = imageData as NSData
        artworkItem.dataType = UTType.jpeg.identifier
        metadata.append(artworkItem)
        exportSession.metadata = metadata
        
        // 7. 执行导出
        if verbose {
            os_log("开始导出文件...")
        }
        
        await exportSession.export()
        
        // 8. 检查导出结果
        if exportSession.status == .completed {
            do {
                // 9. 替换原文件
                if FileManager.default.fileExists(atPath: self.path) {
                    try FileManager.default.removeItem(at: self)
                }
                
                // 10. 移动文件并保持原始扩展名
                let finalURL = self.deletingPathExtension().appendingPathExtension(self.pathExtension)
                try FileManager.default.moveItem(at: temporaryURL, to: finalURL)
                
                if verbose {
                    os_log("成功写入封面到文件：\(self.path)")
                }
            } catch {
                throw CoverWriteError.temporaryFileOperationFailed(error)
            }
        } else {
            if verbose {
                os_log("""
                导出失败：
                - 状态：\(exportSession.status.rawValue)
                - 错误：\(String(describing: exportSession.error))
                - 输出URL：\(String(describing: exportSession.outputURL))
                - 输出类型：\(String(describing: exportSession.outputFileType))
                """)
            }
            throw CoverWriteError.exportFailed(exportSession.error)
        }
    }
    
    /// 专门处理 MP3 文件的封面写入
    private func writeCoverToMP3File(
        imageData: Data,
        verbose: Bool = false
    ) async throws {
        if verbose {
            os_log("使用 ID3TagEditor 处理 MP3 文件：\(self.path)")
        }
        
        do {
            let id3TagEditor = ID3TagEditor()
            
            // 使用 Builder 模式创建标签
            let id3Tag = ID32v3TagBuilder()
                .attachedPicture(
                    pictureType: .frontCover,
                    frame: ID3FrameAttachedPicture(
                        picture: imageData,
                        type: .frontCover,
                        format: .jpeg
                    )
                )
                .build()
            
            // 写入文件
            try id3TagEditor.write(tag: id3Tag, to: self.path)
            
            if verbose {
                os_log("成功写入 MP3 封面")
            }
        } catch {
            if verbose {
                os_log("MP3 封面写入失败：\(error.localizedDescription)")
            }
            throw CoverWriteError.mp3ProcessingFailed(error)
        }
    }
}

#if DEBUG
#Preview {
    ThumbnailPreview()
}
#endif
