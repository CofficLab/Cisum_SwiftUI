import Foundation
import OSLog
import SwiftData

// MARK: 删除

extension DB {
    static func deleteAudio(context: ModelContext, disk: DiskContact, id: Audio.ID) -> Audio? {
        if verbose {
            os_log("\(Logger.isMain)\(self.label)数据库删除")
        }
        
        guard let audio = context.model(for: id) as? Audio else {
            os_log("\(Logger.isMain)\(self.label)删除时找不到")
            return nil
        }
        
        let url = audio.url

        // 找出下一个
        var next = Self.nextOf(context: context, audio: audio)
        if next?.url == url {
            next = nil
        }

        do {
            // set duplicatedOf to nil
            try context.fetch(FetchDescriptor(predicate: #Predicate<Audio> {
                $0.duplicatedOf == url
            })).forEach {
                $0.duplicatedOf = nil
            }

            // 从磁盘删除
            try disk.deleteFile(audio)

            // 从磁盘删除后，因为数据库监听了磁盘的变动，会自动删除
            // 但自动删除可能不及时，所以这里及时删除
            context.delete(audio)

            try context.save()
        } catch let e {
            os_log("\(Logger.isMain)\(DB.label)删除出错 \(e)")
        }

        return next
    }
    
    func deleteIfNotIn(_ urls: [URL]) {
        do {
            try context.delete(model: Audio.self, where: #Predicate {
                urls.contains($0.url) == false
            })

            try context.save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }

    func deleteAudioAndGetNext(_ audio: Audio) -> Audio? {
        delete(audio.id)
    }

    nonisolated func deleteAudio(_ audio: Audio) {
        Task {
            let disk = await self.getDisk()
            _ = Self.deleteAudio(context: ModelContext(self.modelContainer), disk: disk, id: audio.id)
        }
    }
    
    func deleteAudio(_ url: URL) {
        guard let dbAudio = self.findAudio(url) else {
            return
        }
        
        _ = self.delete(dbAudio.id)
    }
    
    func deleteAudios(_ urls: [URL]) {
        urls.forEach({
            deleteAudio($0)
        })
    }

    func deleteAudios(_ audios: [Audio.ID]) -> Audio? {
        var next: Audio?

        for audio in audios {
            next = delete(audio)
        }

        return next
    }

    func delete(_ id: Audio.ID) -> Audio? {
        Self.deleteAudio(context: context, disk: self.disk, id: id)
    }

    func trash(_ audio: Audio) async {
        // 文件已经不存在了，放弃
        if audio.isNotExists {
            return
        }

        // 移动到回收站
        await self.disk.trash(audio)
        
        // 从数据库删除
        self.deleteAudio(audio)
    }

    /// 清空数据库
    func destroy() {
        try? context.delete(model: Audio.self)
        try? context.save()
    }
}
