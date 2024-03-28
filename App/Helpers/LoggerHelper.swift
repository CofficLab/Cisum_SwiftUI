import OSLog

extension Logger {
    static var isMain: String {
        "\(Thread.isMainThread ? "🔥 " : "")"
    }
}
