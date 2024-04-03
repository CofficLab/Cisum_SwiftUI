import Foundation
import SwiftData

@Model
class PlayItem {
    var url: URL
    var order: Int = 0
    
    var title: String { url.lastPathComponent }
    
    init(_ url: URL, order: Int = 0) {
        self.url = url
        self.order = order
    }
}

// MARK: 增删改查

extension PlayItem {
    // MARK: 查找
    
    static func find(_ context: ModelContext, url: URL) -> PlayItem? {
        let predicate = #Predicate<PlayItem> {
            $0.url == url
        }
        var descriptor = FetchDescriptor<PlayItem>(predicate: predicate)
        descriptor.fetchLimit = 1
        do {
            let result = try context.fetch(descriptor)
            if let first = result.first {
                return first
            } else {
                print("not found")
            }
        } catch let e{
            print(e)
        }
        
        return nil
    }
    
    static func find(_ context: ModelContext, index: Int) -> PlayItem? {
        var descriptor = FetchDescriptor<PlayItem>()
        descriptor.fetchLimit = 1 // 限制查询结果为1条记录
        descriptor.fetchOffset = index // 设置偏移量，从0开始
        do {
            let result = try context.fetch(descriptor)
            if let first = result.first {
                return first
            } else {
                print("not found")
            }
        } catch let e{
            print(e)
        }
        
        return nil
    }
    
    static func nextOf(_ context: ModelContext, item: Audio) -> PlayItem? {
        if let current = find(context, url: item.url) {
            print(current.id)
        }
        
        return nil
    }
    
    static func nextOf(_ context: ModelContext, item: PlayItem) -> PlayItem? {
        let id = item.persistentModelID
        let predicate = #Predicate<PlayItem> {
            $0.persistentModelID > id
        }
        var descriptor = FetchDescriptor<PlayItem>(predicate: predicate)
        descriptor.fetchLimit = 1
        do {
            let result = try context.fetch(descriptor)
            if let first = result.first {
                return first
            } else {
                print("not found")
            }
        } catch let e{
            print(e)
        }
        
        return nil
    }
}
