import Foundation
import OSLog

class AudioList {
    var downloaded: [AudioModel] = []
    var downloading: [AudioModel] = []
    var notDownloaded: [AudioModel] = []
    var collection: [AudioModel] { downloaded + downloading + notDownloaded }
    var isEmpty: Bool { collection.isEmpty }
    
    init(_ audios: [AudioModel]) {
        makeCollection(audios)
    }
    
    func shuffle() {
        self.downloaded = downloaded.shuffled()
    }
    
    func makeCollection(_ audios: [AudioModel], shouldShuffle: Bool? = false) {
        audios.forEach({
            if $0.isDownloaded {
                downloaded.append($0)
            } else if $0.isDownloading {
                downloading.append($0)
            } else {
                notDownloaded.append($0)
            }
        })
        
        if shouldShuffle == true {
            downloaded = downloaded.shuffled()
        }
    }
    
    func merge(_ audios: [AudioModel], shouldShuffle: Bool? = false) {
        if self.isEmpty {
            os_log("🍋 AudioList::merge while current is empty")
            return makeCollection(audios, shouldShuffle: shouldShuffle)
        }
        
        audios.forEach { audio in
            if let i = downloading.firstIndex(where: {$0.id == audio.id}) {
                downloading[i] = audio
            }
            
            if let i = notDownloaded.firstIndex(where: {$0.id == audio.id}) {
                notDownloaded[i] = audio
            }
        }
    }
    
    func sort() {
        downloaded = sortUrls(downloaded)
        downloading = sortUrls(downloading)
        notDownloaded = sortUrls(notDownloaded)
    }
    
    func sortUrls(_ audios: [AudioModel]) -> [AudioModel]{
        audios.sorted {
            $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }
    }
    
    func upsert(_ audios: [AudioModel], newValue: AudioModel) -> [AudioModel] {
        let index = audios.firstIndex(of: newValue)
        var newAudios = audios
        if let i = index {
            newAudios[i] = newValue
        } else {
            newAudios.append(newValue)
        }
        
        return newAudios
    }
}
