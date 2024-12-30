import Foundation
import MagicKit
import MagicUI

struct DiskFileGroup: Equatable {
    static func == (lhs: DiskFileGroup, rhs: DiskFileGroup) -> Bool {
        lhs.files == rhs.files
    }
    
    var disk: any SuperStorage
    var files: [DiskFile]
    var isFullLoad: Bool

    var count: Int {
        files.count
    }
    
    var first: DiskFile? {
        files.first
    }
    
    var hashMap: [URL: DiskFile] {
        var hashMap = [URL: DiskFile]()
        for element in files {
            hashMap[element.url] = element
        }
        
        return hashMap
    }
    
    var urls: [URL] { files.map({ $0.url }) }
    
    func find(_ url: URL) -> DiskFile? {
        files.first(where: { $0.url == url})
    }
    
    static func fromURLs(_ urls: [URL], isFullLoad: Bool, disk: any SuperStorage) -> Self {
        DiskFileGroup(disk: disk, files: urls.map({
            DiskFile.fromURL($0)
        }), isFullLoad: isFullLoad)
    }
    
    static func fromMetaCollection(_ collection: MetadataItemCollection, disk: any SuperStorage) -> Self {
        let items = collection.items
        let isFullLoad = collection.name == .NSMetadataQueryDidFinishGathering
        
        return DiskFileGroup(disk: disk, files: items.map({
            DiskFile.fromMetaWrapper($0)
        }), isFullLoad: isFullLoad)
    }
}
