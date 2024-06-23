import CryptoKit
import Foundation
import OSLog
import SwiftData

extension DB {
    var labelForGroup: String { "\(self.label)🌾🌾🌾" }

    func updateGroupForURLs(_ urls: [URL], verbose: Bool = false) {
        let total = urls.count
        let title = "\(labelForGroup) UpdateGroup(\(total))"
        let startTime = DispatchTime.now()
        
        if verbose {
            os_log("\(title) 🚀🚀🚀")
        }

        for (i,url) in urls.enumerated() {
            if verbose && (i+1)%100 == 0 {
                os_log("\(self.labelForGroup) UpdateGroup \(i+1)/\(total) -> \(url.lastPathComponent)")
            }
            
            guard iCloudHelper.isDownloaded(url), let audio = findAudio(url) else {
                continue
            }

            updateHash(audio)
        }
        
        if verbose {
            os_log("\(self.jobEnd(startTime, title: title))")
        }
    }
}
