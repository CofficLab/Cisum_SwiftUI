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
    
    static func fromURLs(_ urls: [URL], isFullLoad: Bool) -> Self {
        DiskFileGroup(files: urls.map({
            DiskFile.fromURL($0)
        }), isFullLoad: isFullLoad)
    }
    
    static func fromMetaCollection(_ collection: MetadataItemCollection) -> Self {
        let items = collection.items
        let isFullLoad = collection.name == .NSMetadataQueryDidFinishGathering
        
        return DiskFileGroup(files: items.map({
            DiskFile(
                url: $0.url!,
                isDownloading: $0.isDownloading,
                isDeleted: $0.isDeleted, 
                downloadProgress: $0.downloadProgress,
                fileName: $0.fileName!
            )
        }), isFullLoad: isFullLoad)
    }
}
