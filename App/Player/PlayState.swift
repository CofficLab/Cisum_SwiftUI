/* 播放状态 */

enum PlayState {
    case Ready(PlayAsset?)
    case Playing(PlayAsset)
    case Paused(PlayAsset?)
    case Stopped
    case Finished(PlayAsset)
    case Error(Error, PlayAsset?)

    var des: String {
        switch self {
        case let .Ready(asset):
            "准备 \(asset?.fileName ?? "nil") 🚀🚀🚀"
        case let .Error(error, asset):
            "错误：\(error.localizedDescription) ⚠️⚠️⚠️ -> \(asset?.fileName ?? "-")"
        case let .Playing(asset):
            "播放 \(asset.fileName) 🔊🔊🔊"
        case let .Paused(asset):
            "暂停 \(asset?.fileName ?? "-") ⏸️⏸️⏸️"
        case let .Finished(asset):
            "完成 \(asset.fileName) 🎉🎉🎉"
        default:
            String(describing: self)
        }
    }
    
    var isReady: Bool {
        if case .Ready = self {
            return true
        } else {
            return false
        }
    }

    var isPlaying: Bool {
        if case .Playing = self {
            return true
        } else {
            return false
        }
    }
    
    var isStopped: Bool {
        if case .Stopped = self {
            return true
        } else {
            return false
        }
    }
    
    var isFinished: Bool {
        if case .Finished = self {
            return true
        } else {
            return false
        }
    }

    var isNotPlaying: Bool {
        !isPlaying
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
        case .Finished(let asset):
            asset
        case .Error(_, let asset):
            asset
        case .Stopped:
            nil
        }
    }
    
    func getError() -> Error? {
        switch self {
        case let .Error(error, _):
            return error
        default:
            return nil
        }
    }
    
    func getPlayingAsset() -> PlayAsset? {
        switch self {
        case let .Playing(asset):
            return asset
        default:
            return nil
        }
    }
}




// MARK: 播放状态

//extension VideoWorker {
//    enum State {
//        case Ready(Audio?)
//        case Playing(Audio)
//        case Paused(Audio?)
//        case Stopped
//        case Finished
//        case Error(Error, Audio?)
//
//        var des: String {
//            switch self {
//            case let .Ready(audio):
//                "准备 \(audio?.title ?? "nil") 🚀🚀🚀"
//            case let .Error(error, audio):
//                "错误：\(error.localizedDescription) ⚠️⚠️⚠️ -> \(audio?.title ?? "-")"
//            case let .Playing(audio):
//                "播放 \(audio.title) 🔊🔊🔊"
//            case let .Paused(audio):
//                "暂停 \(audio?.title ?? "-") ⏸️⏸️⏸️"
//            default:
//                String(describing: self)
//            }
//        }
//
//        func getPausedAudio() -> Audio? {
//            switch self {
//            case let .Paused(audio):
//                return audio
//            default:
//                return nil
//            }
//        }
//        
//        func getAudio() -> Audio? {
//            switch self {
//            case .Ready(let audio):
//                audio
//            case .Playing(let audio):
//                audio
//            case .Paused(let audio):
//                audio
//            case .Error(_, let audio):
//                audio
//            case .Stopped,.Finished:
//                nil
//            }
//        }
//    }
//
//    func setError(_ e: Error, audio: Audio?) {
//        state = .Error(e, audio)
//    }

//}
