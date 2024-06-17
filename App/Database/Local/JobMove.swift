import Foundation
import OSLog
import SwiftData

extension DB {
    static func move() {
        let localDisk = DiskLocal()
        let cloudDisk = DiskiCloud()
        
        if AppConfig.isStoreIniCloud {
            os_log("\(Self.label)将文件从 LocalDisk 移动到 CloudDisk")
            moveAudios(localDisk, cloudDisk)
        } else {
            os_log("\(Self.label)将文件从 CloudDisk 移动到 LocalDisk")
            moveAudios(cloudDisk, localDisk)
        }
    }
    
    static func moveAudios(_ from: DiskContact, _ to: DiskContact, verbose: Bool = false) {
        Task.detached(priority: .low) {
            if verbose {
                os_log("\(Self.label)将文件从 \(from.audiosDir) 移动到 \(to.audiosDir)")
            }
            
            let fileManager = FileManager.default
            do {
                let files = try fileManager.contentsOfDirectory(atPath: from.audiosDir.path()).filter({
                    !$0.hasSuffix(".DS_Store")
                })
                
                for file in files {
                    let sourceURL = URL(fileURLWithPath: from.audiosDir.path()).appendingPathComponent(file)
                    
                    try to.copyTo(url: sourceURL)
                    
                    try fileManager.removeItem(at: sourceURL)
                }
            } catch {
                os_log("Error: \(error)")
            }
        }
    }
}
