import SwiftUI
import OSLog

class DiskManager: ObservableObject {
    @Published var disk: any DiskContact = DiskLocal()
    
    var label: String {
        "\(Logger.isMain)💼 DiskManager::"}
    
    var isiCloudDisk: Bool { ((self.disk as? DiskiCloud) != nil)}
    
    init() {
        if Config.iCloudEnabled {
            self.disk = DiskiCloud()
        }
    }
    
    func changeDisk(_ to: DiskContact) {
        os_log("\(self.label)更新磁盘为 \(to.name)")
        self.disk = to
    }
}

#Preview {
    AppPreview()
}
