import MagicCore
import MagicUI
import MagicAlert
import MagicPlayMan
import OSLog

typealias PlayMan = MagicPlayMan
typealias PlayAsset = MagicAsset
typealias PlayMode = MagicPlayMode
typealias Logger = MagicLogger
typealias MagicCard = MagicUI.MagicCard
typealias MagicApp = MagicCore.MagicApp
typealias SuperLog = MagicCore.SuperLog
typealias MagicLoading = MagicUI.MagicLoading
typealias MagicMessageProvider = MagicAlert.MagicMessageProvider
typealias MagicSettingSection = MagicUI.MagicSettingSection
typealias MagicSettingRow = MagicUI.MagicSettingRow
typealias MagicButton = MagicUI.MagicButton

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
