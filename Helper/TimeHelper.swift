import Foundation

class TimeHelper {
    static func getTimeString(_ time: Date = .now) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        return dateFormatter.string(from: time)
    }
    
    static func getTimeString2(_ time: Date = .now) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: time)
    }
}
