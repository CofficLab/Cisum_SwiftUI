import OSLog

extension Logger {
    static var isMain: String {
        return "\(Thread.isMainThread ? "🔥 " : "")"
    }
}
