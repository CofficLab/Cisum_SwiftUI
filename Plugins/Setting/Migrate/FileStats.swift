import Foundation

struct FileStats: Equatable {
    var downloaded: Int = 0
    var downloading: Int = 0
    var notDownloaded: Int = 0
    
    var isEmpty: Bool {
        downloaded == 0 && downloading == 0 && notDownloaded == 0
    }
}
