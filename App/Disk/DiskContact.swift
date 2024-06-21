import Foundation

protocol DiskContact: ObservableObject {
    var audiosDir: URL { get }
    var onUpdated: (_ items: DiskFileGroup) -> Void { get set }
    
    func clearFolderContents(atPath path: String)
    
    /// 删除一个文件
    func deleteFile(_ audio: Audio) throws
    
    func deleteFiles(_ audios: [Audio]) throws
    
    /// 移除下载
    func evict(_ url: URL)
    
    func download(_ url: URL, reason: String) async
    
    func copyTo(url: URL) throws
    
    func watchAudiosFolder() async
    
    func getDownloadingCount() -> Int
    
    func moveFile(at sourceURL: URL, to destinationURL: URL) 
    
    func makeURL(_ fileName: String) -> URL
    
    func getTree() -> DiskTree
}
