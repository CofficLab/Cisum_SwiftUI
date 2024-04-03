import Foundation
import OSLog

class AudioList {
    var downloaded: [Audio] = []
    var downloading: [Audio] = []
    var notDownloaded: [Audio] = []
    var all: [Audio] { downloaded + downloading + notDownloaded }
    var count: Int { all.count }
    var isEmpty: Bool { all.isEmpty }
    
    init(_ audios: [Audio]) {
        makeCollection(audios)
    }
    
    // MARK: 查找
    
    func notHas(_ audioId: Audio.ID) -> Bool {
        !has(audioId)
    }
    
    func has(_ audioId: Audio.ID) -> Bool {
        (all.firstIndex(where: {audioId == $0.id}) != nil)
    }
    
    func find(_ audioId: Audio.ID) -> Audio? {
        let i = all.firstIndex(where: {audioId == $0.id}) ?? -1
        return all[i]
    }
    
    func find(_ audioId: Audio.ID) -> Int? {
        all.firstIndex(where: {audioId == $0.id})
    }
    
    func get(_ index: Int) -> Audio? {
        if index < 0 || index > count - 1 {
            return nil
        }
        
        return all[index]
    }
    
    func prevOf(_ audioId: Audio.ID) -> Audio {
        if let i: Int = find(audioId) {
            return downloaded[(i-1+downloaded.count)%downloaded.count]
        } else {
            return downloaded[0]
        }
    }
    
    func nextOf(_ audioId: Audio.ID) -> Audio {
        if let i: Int = find(audioId) {
            return downloaded[(i+1)%downloaded.count]
        } else {
            return downloaded[0]
        }
    }
    
    func firstDownloaded() -> Int? {
        downloaded.firstIndex(where: { $0.isDownloaded})
    }
    
    func shuffle() {
        self.downloaded = downloaded.shuffled()
    }
    
    func makeCollection(_ audios: [Audio], shouldShuffle: Bool? = false) {
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
    
    func merge(_ audios: [Audio], shouldShuffle: Bool? = false) {
        os_log("🍋 AudioList::merge \(audios.count)")
        if self.isEmpty {
            os_log("🍋 AudioList::merge while current is empty")
            return makeCollection(audios, shouldShuffle: shouldShuffle)
        }
        
        for audio in audios {
            if let i = downloading.firstIndex(where: {$0.id == audio.id}) {
                if downloading[i] == audio {
                    continue
                }
                
                downloading[i] = audio
                //os_log("🍋 AudioList::merge \(audio.title) into downloading, index=\(i)")
                continue
            }
            
            if let i = notDownloaded.firstIndex(where: {$0.id == audio.id}) {
                if notDownloaded[i] == audio {
                    continue
                }
                
                notDownloaded[i] = audio
                //os_log("🍋 AudioList::merge \(audio.title) into notDownloaded, index=\(i)")
                continue
            }
            
            if let i = downloaded.firstIndex(where: {$0.id == audio.id}) {
                if downloaded[i] == audio {
                    continue
                }
                
                downloaded[i] = audio
                //os_log("🍋 AudioList::merge \(audio.title) into downloaded, index=\(i)")
                continue
            }
            
            if audio.isDownloaded {
                downloaded.append(audio)
            } else if audio.isDownloading {
                downloading.append(audio)
            } else {
                notDownloaded.append(audio)
            }
        }
        
        os_log("🍋 AudioList::merge done 🎉🎉🎉 \(self.all.count)")
    }
    
    func sort() {
        downloaded = sortUrls(downloaded)
        downloading = sortUrls(downloading)
        notDownloaded = sortUrls(notDownloaded)
    }
    
    func sortUrls(_ audios: [Audio]) -> [Audio]{
        audios.sorted {
            $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }
    }
    
    func upsert(_ audios: [Audio], newValue: Audio) -> [Audio] {
        let index = audios.firstIndex(of: newValue)
        var newAudios = audios
        if let i = index {
            newAudios[i] = newValue
        } else {
            newAudios.append(newValue)
        }
        
        return newAudios
    }
    
    func delete(_ id: Audio.ID) -> Self {
        downloaded.removeAll(where: { $0.id == id})
        downloading.removeAll(where: { $0.id == id})
        notDownloaded.removeAll(where: { $0.id == id})
        
        return self
    }
}
