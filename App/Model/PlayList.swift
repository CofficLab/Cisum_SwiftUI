import AVFoundation
import Foundation
import SwiftUI
import OSLog

class PlayList {
    var fileManager = FileManager.default
    var title: String = "[空白]"
    var audios: [AudioModel]
    var playMode: PlayMode = .Random
    var list: [AudioModel] = []
    var current: Int = 0
    var audio: AudioModel { list[current] }
    /// 本地磁盘目录，用来存放缓存
    var localDisk: URL?
    
    init(_ audios: [AudioModel]) {
        os_log("🚩 PlayList::init -> audios.count = \(audios.count)")
        self.audios = audios
        self.list = audios
    }
    
    // MARK: 获取上{offset}曲，仅获取，不改变播放状态
    
    /// 获取上{offset}曲，仅获取，不改变播放状态
    func getPre(_ offset: Int = 1) -> AudioModel {
        if list.count == 0 {
            return AudioModel.empty
        }
        
        let preIndex = (current - offset + list.count)%list.count
        let preAudio = list[preIndex]
        //os_log("🔊 PlayList::next \(offset) -> \(nextAudio.title)")
        
        return preAudio
    }
    
    // MARK: 获取下{offset}曲，仅获取，不改变播放状态
    
    /// 获取下{offset}曲，仅获取，不改变播放状态
    func getNext(_ offset: Int = 1) -> AudioModel {
        if list.count == 0 {
            return AudioModel.empty
        }
        
        let nextIndex = (current + offset)%list.count
        let nextAudio = list[nextIndex]
        //os_log("🔊 PlayList::next \(offset) -> \(nextAudio.title)")
        
        return nextAudio
    }
    
    // MARK: 跳到上{offset}曲
    
    func prev(_ offset: Int = 1, manual: Bool = true) throws -> AudioModel {
        let index = offset%list.count
        os_log("🔊 PlayList::prev \(offset) -> \(self.audio.title)")

        if list.count == 0 {
            os_log("列表为空")
            return AudioModel.empty
        }
        
        for i in index...list.count-1 {
            let target = getPre(i)
            if target.isDownloaded {
                self.current = (current - i + list.count)%list.count
                os_log("🔊 PlayList::goto -> \(self.audio.title)")
                
                return audio
            }
        }
        
        os_log("🐢 接下来的全部都没下载好")
        throw SmartError.NoDownloadedAudio
    }
    
    // MARK: 跳到下{offset}曲
    
    func next(_ offset: Int = 1, manual: Bool = true) throws -> AudioModel {
        let index = offset%list.count
        os_log("🔊 PlayList::next \(offset) ⬇️ \(self.audio.title)")

        if list.count == 0 {
            os_log("列表为空")
            return AudioModel.empty
        }
        
        // 同时准备接下来的歌曲
        Task { prepare() }
        
        for i in index...list.count-1 {
            let target = getNext(i)
            if target.isDownloaded {
                self.current = (current + i)%list.count
                os_log("🔊 PlayList::goto ⬇️ \(self.audio.title)")

                return audio
            }
        }
        
        os_log("🐢 PlayList::next 接下来的全部都没下载好")
        throw SmartError.NoNextDownloadedAudio
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

// MARK: 缓存

extension PlayList {
    var cacheDirName: String { AppConfig.cacheDirName }
    
    var cacheDir: URL? {
        guard let localDisk = localDisk else {
            return nil
        }
        
        let url = localDisk.appending(component: cacheDirName)
        
        var isDirectory: ObjCBool = true
        if !fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) {
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
                os_log("创建缓存目录成功")
            } catch {
                os_log(.error, "创建缓存目录失败\n\(error.localizedDescription)")
            }
            
        }
        
        //os_log("缓存目录 -> \(url.absoluteString)")

        return url
    }
    
    /// 准备接下来的歌曲
    func prepare() {
        let count = min(list.count-1, 10)
        os_log("🔊 PlayList::prepare next \(count) ⏬")
        guard count > 0 else {
            return
        }
        
        for i in 1...count {
            getNext(i).prepare()
        }
        
        // 只是触发了下载，并不代表文件已经下载完成了
        //os_log("🔊 PlayList::prepare next 10 preparing")
    }

    func getCachePath(_ url: URL) -> URL? {
        cacheDir?.appendingPathComponent(url.lastPathComponent)
    }

    func saveToCache(_ url: URL) {
        os_log("DBModel::saveToCache")
        guard let cachePath = getCachePath(url) else {
            return
        }
        
        do {
            try fileManager.copyItem(at: url, to: cachePath)
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }
    
    /// 如果缓存了，返回缓存的URL，否则返回原来的
    func ifCached(_ url: URL) -> URL {
        if isCached(url) {
            return getCachePath(url) ?? url
        }
        
        return url
    }

    func isCached(_ url: URL) -> Bool {
        guard let cachePath = getCachePath(url) else {
            return false
        }
        
        os_log("DBModel::isCached -> \(cachePath.absoluteString)")
        return fileManager.fileExists(atPath: cachePath.path)
    }
    
    func deleteCache(_ url: URL) {
        os_log("DBModel::deleteCache")
        if isCached(url), let cachedPath = getCachePath(url) {
            os_log("DBModel::deleteCache -> delete")
            try? fileManager.removeItem(at: cachedPath)
        }
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }
}
