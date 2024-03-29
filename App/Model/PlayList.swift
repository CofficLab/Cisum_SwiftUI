import AVFoundation
import Foundation
import OSLog
import SwiftUI

class PlayList {
    var fileManager = FileManager.default
    var playMode: PlayMode = .Random
    var fileList: FileList = FileList([])
    var list: [AudioModel.ID] { self.fileList.collection.map { AudioModel($0).id }}
    var current: Int = 0
    var audio: AudioModel { list.isEmpty ? AudioModel.empty : AudioModel(list[current]) }
    var title: String { self.audio.title }
    var isEmpty: Bool { list.isEmpty }
    var count: Int { self.list.count }
    /// 本地磁盘目录，用来存放缓存
    var localDisk: URL?

    init(_ urls: [URL]) {
        os_log("\(Logger.isMain)🚩 PlayList::init -> audios.count = \(urls.count)")
        self.fileList = FileList(urls)
        self.updateCurrent()
    }
    
    func updateCurrent() {
        self.current = self.list.firstIndex(where: { AudioModel($0).isDownloaded }) ?? 0
        os_log("🍋 Playlist::updateCurrent to \(self.current)")
    }

    func find(_ id: AudioModel.ID) -> AudioModel {
        current = list.firstIndex(of: id)!
        return audio
    }

    func merge(_ urls: [URL]) {
        fileList.merge(urls)
    }

    // MARK: 获取上{offset}曲，仅获取，不改变播放状态

    /// 获取上{offset}曲，仅获取，不改变播放状态
    func getPre(_ offset: Int = 1) -> AudioModel {
        if list.count == 0 {
            return AudioModel.empty
        }

        let preIndex = (current - offset + list.count) % list.count
        let preAudio = AudioModel(list[preIndex])
        // os_log("\(Logger.isMain)🔊 PlayList::next \(offset) -> \(nextAudio.title)")

        return preAudio
    }

    // MARK: 获取下{offset}曲，仅获取，不改变播放状态

    /// 获取下{offset}曲，仅获取，不改变播放状态
    func getNext(_ offset: Int = 1) -> AudioModel {
        if list.count == 0 {
            return AudioModel.empty
        }

        let nextIndex = (current + offset) % list.count
        let nextAudio = AudioModel(list[nextIndex])
        
        os_log("\(Logger.isMain)🔊 PlayList::getNext \(offset) while current -> \(self.current) -> \(nextAudio.title)")

        return nextAudio
    }

    // MARK: 跳到上{offset}曲

    func prev(_ offset: Int = 1, manual: Bool = true) throws -> AudioModel {
        if list.count == 0 {
            os_log("\(Logger.isMain)列表为空")
            throw SmartError.NoAudioInList
        }

        let index = offset % list.count
        os_log("\(Logger.isMain)🔊 PlayList::prev \(offset) -> \(self.audio.title)")

        for i in index...list.count - 1 {
            let target = getPre(i)
            if target.isDownloaded {
                current = (current - i + list.count) % list.count
                os_log("\(Logger.isMain)🔊 PlayList::goto -> \(self.audio.title)")

                return audio
            }
        }

        os_log("\(Logger.isMain)🐢 接下来的全部都没下载好")
        throw SmartError.NoDownloadedAudio
    }

    // MARK: 跳到下{offset}曲

    func next(_ offset: Int = 1, manual: Bool = true) throws -> AudioModel {
        os_log("🍋 Playlist::next, current is \(self.current)")
        if list.count == 0 {
            os_log("\(Logger.isMain)列表为空")
            throw SmartError.NoAudioInList
        }

        let index = offset % list.count
        os_log("\(Logger.isMain)🔊 PlayList::next \(offset) ⬇️ \(manual ? "手动触发" : "自动触发")")

        // 用户触发，但曲库仅一首，发出提示
        if list.count == 1 && manual {
            throw SmartError.NoNextAudio
        }

        // 不是用户触发的，且处于单曲循环模式，重复播放当前歌曲
        if playMode == .Loop && manual == false {
            os_log("\(Logger.isMain)🔊 PlayList::next -> Auto Loop")
            return getNext(0)
        }

        // 同时准备接下来的歌曲
        Task { prepare() }

        for i in index...list.count - 1 {
            let target = getNext(i)
            if target.isDownloaded {
                current = (current + i) % list.count
                os_log("\(Logger.isMain)🔊 PlayList::goto ⬇️ \(self.audio.title)")

                return audio
            }
        }

        os_log("\(Logger.isMain)🐢 PlayList::next 接下来的全部都没下载好")
        throw SmartError.NoNextDownloadedAudio
    }

    // MARK: 切换播放模式

    func switchMode(_ callback: @escaping (_ mode: PlayMode) -> Void) {
        switch playMode {
        case .Order:
            playMode = .Random
            fileList.shuffle()
        case .Loop:
            playMode = .Order
            fileList.sort()
        case .Random:
            playMode = .Loop
        }

        callback(playMode)
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
                os_log("\(Logger.isMain)创建缓存目录成功")
            } catch {
                os_log(.error, "创建缓存目录失败\n\(error.localizedDescription)")
            }
        }

        // os_log("\(Logger.isMain)缓存目录 -> \(url.absoluteString)")

        return url
    }

    /// 准备接下来的歌曲
    func prepare() {
        let count = min(list.count - 1, 3)
        os_log("\(Logger.isMain)🔊 PlayList::prepare next \(count) ⏬")
        guard count > 0 else {
            return
        }

        for i in 1...count {
            getNext(i).prepare()
        }

        // 只是触发了下载，并不代表文件已经下载完成了
        // os_log("\(Logger.isMain)🔊 PlayList::prepare next 10 preparing")
    }

    func getCachePath(_ url: URL) -> URL? {
        cacheDir?.appendingPathComponent(url.lastPathComponent)
    }

    func saveToCache(_ url: URL) {
        os_log("\(Logger.isMain)DB::saveToCache")
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

        os_log("\(Logger.isMain)DB::isCached -> \(cachePath.absoluteString)")
        return fileManager.fileExists(atPath: cachePath.path)
    }

    func deleteCache(_ url: URL) {
        os_log("\(Logger.isMain)DB::deleteCache")
        if isCached(url), let cachedPath = getCachePath(url) {
            os_log("\(Logger.isMain)DB::deleteCache -> delete")
            try? fileManager.removeItem(at: cachedPath)
        }
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }
}
