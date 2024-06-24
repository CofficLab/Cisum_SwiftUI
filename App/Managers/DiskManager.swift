import SwiftUI
import OSLog

class DiskManager: ObservableObject {
    static var label = "💼 DiskManager::"
    
    @Published var appScene: AppScene
    @Published var disk: any Disk
    
    var label: String { "\(Logger.isMain)\(Self.label)" }
    var isiCloudDisk: Bool { ((self.disk as? DiskiCloud) != nil)}
    
    init() {
        let verbose = true
        let appScene = AppScene.Music
        self.appScene = appScene
        
        if Config.iCloudEnabled {
            self.disk = DiskiCloud.makeSub(appScene.folderName)
        } else {
            self.disk = DiskLocal.makeSub(appScene.folderName)
        }
        
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)初始化，iCloud=\(Config.iCloudEnabled)")
            os_log("\(Logger.isMain)\(Self.label)初始化，Disk=\(self.disk.name)")
        }
    }
    
    func changeDisk(_ to: Disk) {
        os_log("\(self.label)更新磁盘为 \(to.name)")
        self.disk = to
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
