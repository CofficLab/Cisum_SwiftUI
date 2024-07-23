import OSLog
import Foundation

extension Migrate {
    func migrateTo25(dataManager: DataProvider) {
        os_log("\(self.label)版本升级 -> 2.5")
    }
}
