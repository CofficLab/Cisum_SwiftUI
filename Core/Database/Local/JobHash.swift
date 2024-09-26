import CryptoKit
import Foundation
import OSLog
import SwiftData

extension DB {
    var labelForGroup: String { "\(self.t)🌾🌾🌾" }

    func updateGroupForURLs(_ urls: [URL], verbose: Bool = true) {
        let total = urls.count
        let title = "\(labelForGroup) UpdateHash(\(total))"
        let startTime = DispatchTime.now()
        
        if verbose {
            os_log("\(title) 🚀🚀🚀")
        }

        for (i,url) in urls.enumerated() {
            if verbose && (i+1)%100 == 0 {
                os_log("\(self.labelForGroup) UpdateHash \(i+1)/\(total) -> \(url.lastPathComponent)")
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
