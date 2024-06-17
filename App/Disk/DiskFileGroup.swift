import Foundation

struct DiskFileGroup {
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
    
    static func fromURLs(_ urls: [URL]) -> Self {
        DiskFileGroup(files: urls.map({
            DiskFile.fromURL($0)
        }), isFullLoad: true)
    }
    
    static func fromMetaCollection(_ collection: MetadataItemCollection) -> Self {
        let items = collection.items
        
        return DiskFileGroup.fromURLs(items.map({
            $0.url!
        }))
    }
}
