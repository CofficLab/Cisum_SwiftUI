import Foundation

protocol DiskContact {
    func clearFolderContents(atPath path: String)
    
    /// 删除一个文件
    func deleteFile(_ audio: Audio) throws
    
    /// 移除下载
    func evict(_ url: URL)
}
