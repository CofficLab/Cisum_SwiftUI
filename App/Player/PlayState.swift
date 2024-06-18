enum PlayState {
    case Ready(Audio?)
    case Playing(Audio)
    case Paused(Audio?)
    case Stopped
    case Finished
    case Error(Error, Audio?)

    var des: String {
        switch self {
        case let .Ready(audio):
            "准备 \(audio?.title ?? "nil") 🚀🚀🚀"
        case let .Error(error, audio):
            "错误：\(error.localizedDescription) ⚠️⚠️⚠️ -> \(audio?.title ?? "-")"
        case let .Playing(audio):
            "播放 \(audio.title) 🔊🔊🔊"
        case let .Paused(audio):
            "暂停 \(audio?.title ?? "-") ⏸️⏸️⏸️"
        default:
            String(describing: self)
        }
    }

    func getPausedAudio() -> Audio? {
        switch self {
        case let .Paused(audio):
            return audio
        default:
            return nil
        }
    }
    
    func getAudio() -> Audio? {
        switch self {
        case .Ready(let audio):
            audio
        case .Playing(let audio):
            audio
        case .Paused(let audio):
            audio
        case .Error(_, let audio):
            audio
        case .Stopped,.Finished:
            nil
        }
    }
}
