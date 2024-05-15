import Foundation
import OSLog
import SwiftData
import SwiftUI
import AVKit

extension DB {
    func runGetCoversJob() {
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "GetCover")
        let total = self.getTotal()
        
        // hasCover == nil 表示不确定有没有
        let predicate = #Predicate<Audio> { $0.hasCover == nil }
        
        do {
            context.autosaveEnabled = false
            try context.enumerate(FetchDescriptor<Audio>(predicate: predicate), block: { audio in
                queue.async {
                    group.enter()
                    
                    audio.getCoverFromMeta({url in
                        if url != nil {
                            EventManager().emitAudioUpdate(audio)
                        }
                        
                        group.leave()
                    }, queue: .main)
                }
            })
            
            // 确认 hasCover == nil 的到底有没有
            group.notify(queue: .main, execute: {
                do {
                    try self.context.enumerate(FetchDescriptor<Audio>(predicate: predicate), block: { audio in
                        if audio.isDownloaded {
                            if FileManager.default.fileExists(atPath: audio.coverCacheURL.path) {
                                audio.hasCover = true
                            } else {
                                audio.hasCover = false
                            }
                        }
                    })
                    
                    try self.context.save()
                } catch let e {
                    os_log(.error, "\(e.localizedDescription)")
                }
            })
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }
}
