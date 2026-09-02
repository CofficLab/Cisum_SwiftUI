import Foundation
import OSLog

public extension Migrate {
    func migrateTo25() {
        os_log("\(self.t)版本升级 -> 2.5")
    }
}
