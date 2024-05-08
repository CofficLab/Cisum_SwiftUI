import Foundation

protocol DiskContact {
    var audiosDir: URL { get }
    var onUpdated: (_ items: [MetadataItemWrapper]) -> Void { get set }
    
    func clearFolderContents(atPath path: String)
    
    /// 删除一个文件
    func deleteFile(_ audio: Audio) throws
    
    /// 移除下载
    func evict(_ url: URL)
    
    func trash(_ audio: Audio) async
    
    func download(_ audio: Audio) async
    
    func copyTo(url: URL) throws
    
    func watchAudiosFolder()
    
    func getDownloadingCount() -> Int
}
