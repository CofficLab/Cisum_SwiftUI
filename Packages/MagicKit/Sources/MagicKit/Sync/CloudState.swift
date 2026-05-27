import OSLog
import CloudKit
import Foundation

/// Represent the state of the cloud database
public struct CloudState: Decodable, Encodable, SuperLog, SuperThread {
    public nonisolated static let emoji = "🍽️"
    
    var url: URL
    
    private var fileManager: FileManager {
        FileManager.default
    }
    
    struct CloudStateData: Codable {
        var stateSerialization: CKSyncEngine.State.Serialization?
        var updatedAt: Date
    }
    
    init(reason: String, url: URL) throws {
        let verbose = false
        if verbose {
            os_log("\(Self.i) CloudState(\(reason))")
        }
        
        self.url = url
    }
    
    func getState() -> CKSyncEngine.State.Serialization? {
        let verbose = false
        
        if !fileManager.fileExists(atPath: url.path()) {
            return nil
        }
        
        do {
            let blob = try Data(contentsOf: url)
            
            guard !blob.isEmpty else {
                return nil
            }
            
            let data = try JSONDecoder().decode(CloudStateData.self, from: blob)

            if verbose {
                os_log("\(self.t)从磁盘解析 CloudState 成功，更新时间 \(data.updatedAt.logTime)")
            }
            
            return data.stateSerialization
        } catch let error as DecodingError {
            switch error {
            case .dataCorrupted(let context):
                os_log(.error, "\(self.t)数据损坏: \(context.debugDescription)")
            case .keyNotFound(let key, let context):
                os_log(.error, "\(self.t)缺少键 '\(key.stringValue)'：\(context.debugDescription)")
            case .typeMismatch(let type, let context):
                os_log(.error, "\(self.t)类型不匹配 '\(type)'：\(context.debugDescription)")
            case .valueNotFound(let value, let context):
                os_log(.error, "\(self.t)值 '\(value)' 未找到：\(context.debugDescription)")
            @unknown default:
                os_log(.error, "\(self.t)未知的解码错误")
            }
            return nil
        } catch {
            os_log(.error, "\(self.t)从磁盘解析 CloudState 失败 -> \(error.localizedDescription)")
            os_log(.error, "\(self.t)\(error)")
            
            if let content = try? url.getContent() {
                os_log(.error, "\(self.t)\(content)")
            }
            
            return nil
        }
    }
    
    func updateState(_ state: CKSyncEngine.State.Serialization?) throws {
        let verbose = false
        
        if verbose {
            os_log("\(self.t)Save CloudState")
        }
        
        let data = CloudStateData(stateSerialization: state, updatedAt: Date())
        do {
            let data = try JSONEncoder().encode(data)
            try data.write(to: url)
        } catch {
            os_log(.error, "\(self.t)Failed to save to disk: \(error)")
            
            throw CloudState.Error.saveFailed(error.localizedDescription)
        }
    }
}

// MARK: Error

extension CloudState {
    public enum Error: LocalizedError {
        case saveFailed(String)
    }
}
