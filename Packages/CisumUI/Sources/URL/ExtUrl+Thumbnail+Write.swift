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
            return "File does not exist: \(path)"
        case .fileNotWritable(let path):
            return "File is not writable: \(path)"
        case .exportSessionCreationFailed:
            return "Failed to create export session"
        case .exportFailed(let error):
            if let error = error as NSError? {
                return """
                Export failed:
                - Description: \(error.localizedDescription)
                - Domain: \(error.domain)
                - Code: \(error.code)
                - Details: \(error.userInfo)
                """
            }
            return "Export failed: \(error?.localizedDescription ?? "Unknown error")"
        case .temporaryFileOperationFailed(let error):
            return "Temporary file operation failed: \(error.localizedDescription)"
        case .mp3ProcessingFailed(let error):
            return "MP3 file processing failed: \(error?.localizedDescription ?? "Unknown error")"
        case .wavProcessingFailed(let error):
            return "WAV file processing failed: \(error?.localizedDescription ?? "Unknown error")"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .fileNotExists:
            return "The selected file path could not be found."
        case .fileNotWritable:
            return "The app does not have permission to write this file."
        case .exportSessionCreationFailed:
            return "The file format may be unsupported or system resources may be low."
        case .exportFailed:
            return "The file format may be incompatible or disk space may be low."
        case .temporaryFileOperationFailed:
            return "Disk space or file permissions may have prevented the operation."
        case .mp3ProcessingFailed:
            return "The MP3 metadata writer could not update the file."
        case .wavProcessingFailed:
            return "The WAV metadata writer could not update the file."
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .fileNotExists:
            return "Choose an existing audio file."
        case .fileNotWritable:
            return "Grant write permission for this file, then try again."
        case .exportSessionCreationFailed:
            return "Try another audio format or restart the app."
        case .exportFailed:
            return "Try converting the file to M4A before adding artwork."
        case .temporaryFileOperationFailed:
            return "Check disk space and file permissions."
        case .mp3ProcessingFailed:
            return "Check that the MP3 file is valid and writable."
        case .wavProcessingFailed:
            return "Check that the WAV file is valid and writable."
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
                Export failed:
                - Status: \(exportSession.status.rawValue)
                - Error: \(String(describing: exportSession.error))
                - Output URL: \(String(describing: exportSession.outputURL))
                - Output file type: \(String(describing: exportSession.outputFileType))
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
