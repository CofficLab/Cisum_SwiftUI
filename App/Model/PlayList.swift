import AVFoundation
import Foundation
import SwiftUI
import OSLog

class PlayList {
    var title: String = "[空白]"
    var audio: AudioModel = AudioModel.empty
    var audios: [AudioModel]
    var playMode: PlayMode = .Random
    var list: [AudioModel] = []
    
    init(_ audios: [AudioModel]) {
        os_log("🚩 PlayList::init -> audios.count = \(audios.count)")
        self.audios = audios
        self.list = audios
        if self.list.count > 0 {
            self.audio = self.list.first!
        }
    }
    
    func getNext() -> AudioModel {
        if list.count == 0 {
            return AudioModel.empty
        }
        
        if audio.isEmpty() {
            return list.first!
        }
        
        let index = list.firstIndex(of: audio)!
        let audio = list[index + 1 >= list.count ? 0 : index + 1]
        self.audio = audio
        os_log("下一曲是: \(audio.title)")
        
        return audio
    }
    
    
    func prev() -> AudioModel {
        os_log("获取上一曲")

        if audios.count == 0 {
            return AudioModel.empty
        }
        
        let index = list.firstIndex(of: audio)!
        audio = list[index - 1 >= 0 ? index - 1 : list.count - 1]
        os_log("顺序模式，上一曲是: \(self.audio.title)")
        return audio
    }
    
    func next(manual: Bool = true) -> AudioModel {
        os_log("PlayList::next，当前为 -> \(self.audio.title)")

        if list.count == 0 {
            os_log("列表为空")
            return AudioModel.empty
        }
        
        if audio.isEmpty() {
            return list.first!
        }
        
        let index = list.firstIndex(of: audio)!
        audio = list[index + 1 >= list.count ? 0 : index + 1]
        os_log("下一曲是: \(self.audio.title)")
        
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
