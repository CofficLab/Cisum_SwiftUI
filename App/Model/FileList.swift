import Foundation
import OSLog

class FileList {
    var downloaded: [URL] = []
    var downloading: [URL] = []
    var notDownloaded: [URL] = []
    var collection: [URL] { downloaded + downloading + notDownloaded }
    var isEmpty: Bool { collection.isEmpty }
    
    init(_ urls: [URL]) {
        makeCollection(urls)
    }
    
    func shuffle() {
        self.downloaded = downloaded.shuffled()
    }
    
    func makeCollection(_ urls: [URL], shouldShuffle: Bool? = false) {
        urls.forEach({
            if iCloudHelper.isDownloaded(url: $0) {
                downloaded.append($0)
            } else if iCloudHelper.isDownloading($0) {
                downloading.append($0)
            } else {
                notDownloaded.append($0)
            }
        })
        
        if shouldShuffle == true {
            downloaded = downloaded.shuffled()
        }
    }
    
    func merge(_ urls: [URL], shouldShuffle: Bool? = false) {
        if self.isEmpty {
            os_log("🍋 Playlist::merge while current is empty")
            return makeCollection(urls, shouldShuffle: shouldShuffle)
        }
        
        urls.forEach {
            if iCloudHelper.isDownloaded(url: $0) {
                downloaded.append($0)
            } else if iCloudHelper.isDownloading($0) {
                downloading.append($0)
            } else {
                notDownloaded.append($0)
            }
        }
    }
    
    func sort() {
        downloaded = sortUrls(downloaded)
        downloading = sortUrls(downloading)
        notDownloaded = sortUrls(notDownloaded)
    }
    
    func sortUrls(_ urls: [URL]) -> [URL]{
        urls.sorted {
            $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent)
            == .orderedAscending
        }
    }
}
