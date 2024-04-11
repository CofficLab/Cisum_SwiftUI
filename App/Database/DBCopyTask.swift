import Foundation
import OSLog
import SwiftData

// MARK: 增加

extension DB {
    func insert(_ task: CopyTask) {
        context.insert(task)
        try? context.save()
    }

    func add(_ urls: [URL],
             completionAll: @escaping () -> Void,
             completionOne: @escaping (_ sourceUrl: URL) -> Void,
             onStart: @escaping (_ audio: Audio) -> Void)
    {
        for url in urls {
            onStart(Audio(url))

            add(url, completion: {
                completionOne(url)
            })
        }

        completionAll()
    }

    func add(
        _ url: URL,
        completion: @escaping () -> Void
    ) {
        let task = CopyTask(url: url)
        context.insert(task)
        self.save()
        completion()
    }
}

// MARK: 删除

extension DB {
    func deleteCopyTasks(_ urls: [URL]) {
        try? self.context.delete(model: CopyTask.self, where: #Predicate {
            urls.contains($0.url)
        })

        self.save()
    }
}

// MARK: 查询

extension DB {}
