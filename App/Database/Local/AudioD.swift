import Foundation
import OSLog
import SwiftData

extension DB {
    // MARK: Static-删除-单个

    static func deleteAudio(context: ModelContext, disk: any Disk, id: Audio.ID) -> Audio? {
        deleteAudios(context: context, disk: disk, ids: [id])
    }

    // MARK: Static-删除-多个

    static func deleteAudiosByURL(context: ModelContext, disk: any Disk, urls: [URL]) -> Audio? {
        // 本批次的最后一个删除后的下一个
        var next: Audio?

        for (index, url) in urls.enumerated() {
            do {
                guard let audio = try context.fetch(FetchDescriptor(predicate: #Predicate<Audio> {
                    $0.url == url
                })).first else {
                    os_log(.debug, "\(Logger.isMain)\(label)删除时找不到")
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
                disk.deleteFile(audio.url)

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

    static func deleteAudios(context: ModelContext, disk: any Disk, ids: [Audio.ID], verbose: Bool = false) -> Audio? {
        if verbose {
            os_log("\(Logger.isMain)\(label)数据库删除")
        }

        // 本批次的最后一个删除后的下一个
        var next: Audio?

        for (index, id) in ids.enumerated() {
            guard let audio = context.model(for: id) as? Audio else {
                os_log(.debug, "\(Logger.isMain)\(label)删除时找不到")
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
                disk.deleteFile(audio.url)

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
//        _ = Self.deleteAudio(context: context, disk: disk, id: audio.id)
    }

    func delete(_ id: Audio.ID) -> Audio? {
//        Self.deleteAudio(context: context, disk: disk, id: id)
        nil
    }

    func deleteAudio(_ url: URL) -> Audio? {
        os_log("\(self.t)DeleteAudio by url=\(url.lastPathComponent)")
        return deleteAudios([url])
    }

    // MARK: 删除多个

    func deleteAudios(_ urls: [URL]) -> Audio? {
        var audio: Audio? = nil
        
        for url in urls {
            audio = deleteAudio(url)
        }
        
        return audio
    }

    func deleteAudios(_ ids: [Audio.ID]) -> Audio? {
//        Self.deleteAudios(context: context, disk: disk, ids: ids)
        nil
    }

    func deleteAudios(_ audios: [Audio]) -> Audio? {
//        Self.deleteAudios(context: context, disk: disk, ids: audios.map { $0.id })
        nil
    }

    // MARK: 清空数据库

    func destroyAudios() {
        do {
            try destroy(for: Audio.self)
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }
}
