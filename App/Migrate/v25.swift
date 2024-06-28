import OSLog
import Foundation

extension Migrate {
    func migrateTo25(dataManager: DataManager) {
        os_log("\(self.label)版本升级 -> 2.5")
    }
}
