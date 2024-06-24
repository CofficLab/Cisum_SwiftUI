import Foundation
import OSLog
import SwiftData

extension DB {
    static func migrate() {
        let localDisk = DiskLocal()
        let cloudDisk = DiskiCloud()
        
        if Config.iCloudEnabled {
            os_log("\(Self.label)将文件从 LocalDisk 移动到 CloudDisk 🚛🚛🚛")
            moveAudios(localDisk, cloudDisk)
        } else {
            os_log("\(Self.label)将文件从 CloudDisk 移动到 LocalDisk 🚛🚛🚛")
            moveAudios(cloudDisk, localDisk)
        }
    }
    
    static func moveAudios(_ from: any Disk, _ to: any Disk, verbose: Bool = true) {
        Task.detached(priority: .low) {
            if verbose {
                os_log("\(Self.label)将文件从 \(from.root.path) 移动到 \(to.root.path)")
            }
            
            let fileManager = FileManager.default
            do {
                let files = try fileManager.contentsOfDirectory(atPath: from.root.path).filter({
                    !$0.hasSuffix(".DS_Store")
                })
                
                for file in files {
                    let sourceURL = URL(fileURLWithPath: from.root.path).appendingPathComponent(file)
                    let destnationURL = to.makeURL(file)
                    
                    if verbose {
                        os_log("\(Self.label)移动 \(sourceURL.lastPathComponent)")
                    }
                    from.moveFile(at: sourceURL, to: destnationURL)
                }
            } catch {
                os_log("Error: \(error)")
            }
        }
    }
}
