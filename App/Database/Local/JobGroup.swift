import CryptoKit
import Foundation
import OSLog
import SwiftData

extension DB {
    var labelForGroup: String { "\(self.label)🌾🌾🌾" }

    func updateGroupForURLs(_ urls: [URL], verbose: Bool = true) {
        let total = urls.count
        let title = "\(labelForGroup) UpdateGroup(\(total))"
        let startTime = DispatchTime.now()
        
        if verbose {
            os_log("\(title) 🚀🚀🚀")
        }

        for (i,url) in urls.enumerated() {
            if verbose {
                os_log("\(self.labelForGroup) UpdateGroup \(i)/\(total)")
            }
            
            guard iCloudHelper.isDownloaded(url), let audio = findAudio(url) else {
                continue
            }

            let fileHash = audio.getHash()
            if fileHash.count > 0 {
                audio.group = AudioGroup(title: audio.title, hash: fileHash)
            }
        }

        do {
            try context.save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
        
        if verbose {
            os_log("\(self.jobEnd(startTime, title: title))")
        }
    }
}
