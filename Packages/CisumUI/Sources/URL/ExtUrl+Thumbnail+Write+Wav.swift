import Foundation
import OSLog

/// WAV 文件的元数据处理
extension URL {
    /// WAV 文件结构
    private struct WAVStructure {
        struct ChunkHeader {
            let id: [UInt8]    // 4 bytes
            let size: UInt32   // 4 bytes
            
            init(id: String, size: UInt32) {
                self.id = Array(id.utf8)
                self.size = size
            }
            
            var data: Data {
                var data = Data(id)
                data.append(contentsOf: withUnsafeBytes(of: size) { Data($0) })
                return data
            }
        }
        
        struct RIFFHeader {
            var riffChunk: ChunkHeader  // "RIFF"
            var format: [UInt8]         // "WAVE"
            
            init(fileSize: UInt32) {
                self.riffChunk = ChunkHeader(id: "RIFF", size: fileSize)
                self.format = Array("WAVE".utf8)
            }
            
            var data: Data {
                var data = riffChunk.data
                data.append(contentsOf: format)
                return data
            }
        }
    }
    
    /// 写入封面到 WAV 文件
    func writeCoverToWAVFile(
        imageData: Data,
        verbose: Bool = false
    ) async throws {
        if verbose {
            os_log("使用 LIST-INFO chunk 处理 WAV 文件：\(self.path)")
        }
        
        // 1. 读取原始文件
        let originalData = try Data(contentsOf: self)
        
        // 2. 创建备份
        let backupURL = self.appendingPathExtension("bak")
        if FileManager.default.fileExists(atPath: backupURL.path) {
            try FileManager.default.removeItem(at: backupURL)
        }
        try FileManager.default.copyItem(at: self, to: backupURL)
        
        do {
            // 3. 准备 LIST chunk 数据
            let imageChunkData = try createListInfoChunk(imageData: imageData)
            
            // 4. 创建新的文件内容
            var newData = Data()
            
            // RIFF header (12 bytes)
            let totalSize = UInt32(originalData.count + imageChunkData.count - 8)
            let riffHeader = WAVStructure.RIFFHeader(fileSize: totalSize)
            newData.append(riffHeader.data)
            
            // 复制原始数据（除了RIFF头）
            newData.append(originalData[12...])
            
            // 添加 LIST-INFO chunk
            newData.append(imageChunkData)
            
            // 5. 写入文件
            try newData.write(to: self)
            
            // 6. 删除备份
            try FileManager.default.removeItem(at: backupURL)
            
            if verbose {
                os_log("成功写入 WAV 封面")
            }
        } catch {
            if verbose {
                os_log("WAV 封面写入失败：\(error.localizedDescription)")
            }
            
            // 恢复备份
            if FileManager.default.fileExists(atPath: backupURL.path) {
                _ = try? FileManager.default.replaceItemAt(self, withItemAt: backupURL)
            }
            
            throw CoverWriteError.wavProcessingFailed(error)
        }
    }
    
    /// 创建 LIST-INFO chunk
    private func createListInfoChunk(imageData: Data) throws -> Data {
        var chunkData = Data()
        
        // LIST chunk header
        let listHeader = WAVStructure.ChunkHeader(
            id: "LIST",
            size: UInt32(4 + 8 + imageData.count)  // "INFO" + "IART" + size + image data
        )
        chunkData.append(listHeader.data)
        
        // INFO type
        chunkData.append(contentsOf: Array("INFO".utf8))
        
        // IART sub-chunk
        let iartHeader = WAVStructure.ChunkHeader(
            id: "IART",
            size: UInt32(imageData.count)
        )
        chunkData.append(iartHeader.data)
        
        // Image data
        chunkData.append(imageData)
        
        // Pad to even length if needed
        if chunkData.count % 2 != 0 {
            chunkData.append(0)
        }
        
        return chunkData
    }
} 