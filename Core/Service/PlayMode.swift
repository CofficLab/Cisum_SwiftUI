/* 播放模式 */

enum PlayMode: String {
    case Order
    case Loop
    case Random

    var description: String {
        switch self {
        case .Order:
            return "顺序播放"
        case .Loop:
            return "单曲循环"
        case .Random:
            return "随机播放"
        }
    }

    func switchMode() -> Self {
        var mode: PlayMode = .Order
        switch self {
        case .Order:
            mode = .Random
        case .Loop:
            mode = .Order
        case .Random:
            mode = .Loop
        }

        return mode
    }
    
    func getImageName() -> String {
        switch self {
        case .Order:
            return "repeat"
        case .Loop:
            return "repeat.1"
        case .Random:
            return "shuffle"
        }
    }
}
