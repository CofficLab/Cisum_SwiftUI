import MagicKit
import MagicPlayMan
import OSLog

typealias PlayMan = MagicPlayMan
typealias PlayAsset = MagicAsset
typealias PlayMode = MagicPlayMode
typealias Logger = MagicLogger
typealias MagicCard = MagicKit.MagicCard
typealias MagicApp = MagicKit.MagicApp
typealias SuperLog = MagicKit.SuperLog

// 创建便捷的日志函数
func info(_ message: String) {
    Logger.info(message)
}

func debug(_ message: String) {
    Logger.debug(message)
}

func warning(_ message: String) {
    Logger.warning(message)
}

func error(_ message: String) {
    Logger.error(message)
}
