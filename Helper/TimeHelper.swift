import Foundation

class TimeHelper {
    static func getTimeString(_ time: Date = .now) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        return dateFormatter.string(from: time)
    }
}
