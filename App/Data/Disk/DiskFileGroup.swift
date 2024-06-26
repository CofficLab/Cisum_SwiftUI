import Foundation

struct DiskFileGroup: Equatable {
    static var empty = DiskFileGroup(files: [], isFullLoad: true)
    
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
    
    static func fromURLs(_ urls: [URL], isFullLoad: Bool) -> Self {
        DiskFileGroup(files: urls.map({
            DiskFile.fromURL($0)
        }), isFullLoad: isFullLoad)
    }
    
    static func fromMetaCollection(_ collection: MetadataItemCollection) -> Self {
        let items = collection.items
        let isFullLoad = collection.name == .NSMetadataQueryDidFinishGathering
        
        return DiskFileGroup(files: items.map({
            DiskFile.fromMetaWrapper($0)
        }), isFullLoad: isFullLoad)
    }
}
