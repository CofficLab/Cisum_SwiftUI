import Foundation
import OSLog
import SwiftData

extension DB {
    // MARK: Static-删除-单个

    static func deleteAudio(context: ModelContext, disk: DiskContact, id: Audio.ID) -> Audio? {
        deleteAudios(context: context, disk: disk, ids: [id])
    }

    // MARK: Static-删除-多个

    static func deleteAudiosByURL(context: ModelContext, disk: DiskContact, urls: [URL]) -> Audio? {
        // 本批次的最后一个删除后的下一个
        var next: Audio?

        for (index, url) in urls.enumerated() {
            do {
                guard let audio = try context.fetch(FetchDescriptor(predicate: #Predicate<Audio> {
                    $0.url == url
                })).first else {
                    os_log(.debug, "\(Logger.isMain)\(self.label)删除时找不到")
                    continue
                }

                // 找出本批次的最后一个删除后的下一个
                if index == urls.count - 1 {
                    next = Self.nextOf(context: context, audio: audio)

                    // 如果下一个等于当前，设为空
                    if next?.url == url {
                        next = nil
                    }
                }

                // 从磁盘删除
                try disk.deleteFile(audio)

                // 从磁盘删除后，因为数据库监听了磁盘的变动，会自动删除
                // 但自动删除可能不及时，所以这里及时删除
                context.delete(audio)

                try context.save()
            } catch let e {
                os_log(.error, "\(Logger.isMain)\(DB.label)删除出错 \(e)")
            }
        }

        return next
    }

    static func deleteAudios(context: ModelContext, disk: DiskContact, ids: [Audio.ID]) -> Audio? {
        if verbose {
            os_log("\(Logger.isMain)\(self.label)数据库删除")
        }

        // 本批次的最后一个删除后的下一个
        var next: Audio?

        for (index, id) in ids.enumerated() {
            guard let audio = context.model(for: id) as? Audio else {
                os_log(.debug, "\(Logger.isMain)\(self.label)删除时找不到")
                continue
            }

            let url = audio.url

            // 找出本批次的最后一个删除后的下一个
            if index == ids.count - 1 {
                next = Self.nextOf(context: context, audio: audio)

                // 如果下一个等于当前，设为空
                if next?.url == url {
                    next = nil
                }
            }

            do {
                // 从磁盘删除
                try disk.deleteFile(audio)

                // 从磁盘删除后，因为数据库监听了磁盘的变动，会自动删除
                // 但自动删除可能不及时，所以这里及时删除
                context.delete(audio)

                try context.save()
            } catch let e {
                os_log(.error, "\(Logger.isMain)\(DB.label)删除出错 \(e)")
            }
        }

        return next
    }

    func deleteAudioAndGetNext(_ audio: Audio) -> Audio? {
        delete(audio.id)
    }

    // MARK: 删除一个

    func deleteAudio(_ audio: Audio) {
        _ = Self.deleteAudio(context: context, disk: disk, id: audio.id)
    }

    func delete(_ id: Audio.ID) -> Audio? {
        Self.deleteAudio(context: context, disk: self.disk, id: id)
    }

    func deleteAudio(_ url: URL) {
        os_log("\(self.label)DeleteAudio by url=\(url.lastPathComponent)")
        self.deleteAudios([url])
    }

    // MARK: 删除多个

    func deleteAudios(_ urls: [URL]) {
        for url in urls {
            deleteAudio(url)
        }
    }

    func deleteAudios(_ ids: [Audio.ID]) -> Audio? {
        Self.deleteAudios(context: context, disk: disk, ids: ids)
    }

    // MARK: 回收站

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

    // MARK: 清空数据库

    func destroyAudios() {
        do {
            try self.destroy(for: Audio.self)
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }
}
