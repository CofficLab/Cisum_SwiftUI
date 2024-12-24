import CloudKit
import OSLog
import Foundation

extension Config {
    static func ifLogged(_ callback: @escaping (_ hasLoggedIn: Bool) -> Void) {
        os_log("\(self.t) ☁️ 检查是否已经登录 iCloud")
        CKContainer.default().accountStatus { status, error in
            switch status {
            case .available:
                os_log("\(self.t) ☁️ 检查iCloud状态 -> 已登录")
                callback(true)
            default:
                os_log("\(self.t) ☁️ 检查iCloud状态 -> 未登录")
                callback(false)
            }
            if let error = error {
                os_log("\(self.t) ☁️ 检查iCloud状态 -> 出现错误 \(error)")
            }
        }
    }

    static func getUserId(_ callback: @escaping (_ id: String) -> Void) {
        os_log("\(self.t) 🍚 获取 iCloud 用户 ID")

        ifLogged({ logged in
            if !logged {
                return callback("")
            }

            CKContainer.default().fetchUserRecordID { recordID, error in
                if let error = error {
                    os_log(.error,"\(self.t) Failed to fetch user record ID: \(error)")
                    return callback("")
                }

                if let recordID = recordID {
                    os_log("\(self.t) 🍚 UserID 为 \(recordID.recordName)")
                    callback(recordID.recordName)
                } else {
                    os_log(.error,"\(self.t) UserID 为 nil")
                    callback("")
                }
            }
        })
    }

    static func checkAccountStatus() {
        os_log("\(self.t) ☁️ 检查iCloud状态")
        CKContainer.default().accountStatus { status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    os_log("\(self.t) ☁️ 检查iCloud状态-> 已登录")
                default:
                    os_log("\(self.t) ☁️ 检查iCloud状态-> 未登录")
                }
                if let error = error {
                    os_log("\(self.t) 检查iCloud状态-> 出现错误 \(error)")
                }
            }
        }

        getUserId { id in
            os_log("\(self.t) ☁️☁️☁️ User Record ID: \(id)")
        }
    }
}
