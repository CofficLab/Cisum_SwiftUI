import SwiftUI
import OSLog

class DiskManager: ObservableObject {
    @Published var appScene: AppScene
    @Published var disk: any Disk
    
    var label: String {
        "\(Logger.isMain)💼 DiskManager::"}
    
    var isiCloudDisk: Bool { ((self.disk as? DiskiCloud) != nil)}
    
    init() {
        let appScene = AppScene.Music
        self.appScene = appScene
        
        if Config.iCloudEnabled {
            self.disk = DiskiCloud.makeSub(appScene.folderName)
        } else {
            self.disk = DiskLocal.makeSub(appScene.folderName)
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
