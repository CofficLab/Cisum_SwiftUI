/* 播放状态 */

enum PlayState {
    case Ready(PlayAsset?)
    case Playing(PlayAsset)
    case Paused(PlayAsset?)
    case Stopped
    case Finished
    case Error(Error, PlayAsset?)

    var des: String {
        switch self {
        case let .Ready(asset):
            "准备 \(asset?.title ?? "nil") 🚀🚀🚀"
        case let .Error(error, asset):
            "错误：\(error.localizedDescription) ⚠️⚠️⚠️ -> \(asset?.title ?? "-")"
        case let .Playing(asset):
            "播放 \(asset.title) 🔊🔊🔊"
        case let .Paused(asset):
            "暂停 \(asset?.title ?? "-") ⏸️⏸️⏸️"
        default:
            String(describing: self)
        }
    }

    func getPausedAudio() -> PlayAsset? {
        switch self {
        case let .Paused(asset):
            return asset
        default:
            return nil
        }
    }
    
    func getAsset() -> PlayAsset? {
        switch self {
        case .Ready(let asset):
            asset
        case .Playing(let asset):
            asset
        case .Paused(let asset):
            asset
        case .Error(_, let asset):
            asset
        case .Stopped,.Finished:
            nil
        }
    }
}
