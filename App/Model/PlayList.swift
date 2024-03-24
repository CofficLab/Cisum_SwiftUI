import AVFoundation
import Foundation
import SwiftUI
import OSLog

class PlayList {
    var title: String = "[空白]"
    var audios: [AudioModel]
    var playMode: PlayMode = .Random
    var list: [AudioModel] = []
    var current: Int = 0
    var audio: AudioModel { list[current] }
    
    init(_ audios: [AudioModel]) {
        os_log("🚩 PlayList::init -> audios.count = \(audios.count)")
        self.audios = audios
        self.list = audios
    }
    
    // MARK: 获取下一曲
    
    func getNext() -> AudioModel {
        if list.count == 0 {
            return AudioModel.empty
        }
        
        let nextIndex = current + 1 >= list.count ? 0 : current + 1
        let nextAudio = list[nextIndex]
        os_log("🔊 PlayList::列表中下一曲是: \(nextAudio.title)")
        
        nextAudio.download()
        
        return nextAudio
    }
    
    // MARK: 跳到上一曲
    
    func prev() -> AudioModel {
        os_log("跳到上一曲")

        if audios.count == 0 {
            return AudioModel.empty
        }
        
        self.current = current - 1 >= 0 ? current - 1 : list.count - 1
        os_log("上一曲是: \(self.audio.title)")
        return audio
    }
    
    // MARK: 跳到下一曲
    
    func next(manual: Bool = true) -> AudioModel {
        os_log("🔊 PlayList::next 当前 -> \(self.audio.title)")

        if list.count == 0 {
            os_log("列表为空")
            return AudioModel.empty
        }
        
        self.current = current + 1 >= list.count ? 0 : current + 1
        os_log("🔊 PlayList::next 跳到 -> \(self.audio.title)")
        
        return audio
    }
    
    func switchPlayMode(_ callback: @escaping (_ mode: PlayMode) -> Void) {
        switch playMode {
        case .Order:
            playMode = .Random
        case .Loop:
            playMode = .Order
        case .Random:
            playMode = .Loop
        }

        callback(playMode)
    }
    
    private func refreshList() {
        switch playMode {
        case .Order:
            list = audios
        case .Loop:
            list = audios
        case .Random:
            list = audios.shuffled()
        }
    }

    private func randomExcludeCurrent() -> AudioModel {
        if audios.count == 1 {
            os_log("只有一条，随机选一条就是第一条")
            return audios.first!
        }

        let result = (audios.filter { $0 != audio }).randomElement()!
        os_log("共 \(self.audios.count) 条，随机选一条: \(result.title)")

        return result
    }
}

extension PlayList: Identifiable {
    var id: String { title }
}

// MARK: 播放模式

extension PlayList {
    enum PlayMode {
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
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
