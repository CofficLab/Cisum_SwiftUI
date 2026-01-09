import Foundation
import OSLog
import SwiftData
import MagicKit
import SwiftUI

extension AudioDB {
    func prepareJob() async throws {
        os_log("\(self.t) 🚀🚀🚀 Prepare")

        let audio = try firstAudio()

        if let audio = audio {
            try await self.downloadNextBatch(audio, reason: "\(self.t)prepare")
        }
    }
}

extension AudioDB {
    func updateGroupForURLs(_ urls: [URL], verbose: Bool = true) {
        let total = urls.count
        let title = "\(t) UpdateHash(\(total))"
        let startTime = DispatchTime.now()

        if verbose {
            os_log("\(title) 🚀🚀🚀")
        }

        for (i, url) in urls.enumerated() {
            if verbose && (i + 1) % 100 == 0 {
                os_log("\(self.t) UpdateHash \(i + 1)/\(total) -> \(url.lastPathComponent)")
            }

            guard url.isDownloaded, let audio = findAudio(url) else {
                continue
            }

            updateHash(audio)
        }

        if verbose {
            os_log("\(self.jobEnd(startTime, title: title))")
        }
    }
}

extension AudioDB {
    var labelForDelete: String { "\(t)🗑️🗑️🗑️" }

    func runDeleteInvalidJob() throws {
        os_log("\(self.t)🚀🚀🚀")

        do {
            try context.enumerate(AudioModel.descriptorAll, block: { audio in
                if !FileManager.default.fileExists(atPath: audio.url.path) {
                    os_log(.error, "\(self.t)磁盘文件已不存在，删除数据库记录 -> \(audio.title)")
                    try self.deleteAudio(audio, verbose: true)
                }
            })
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }
}

extension DispatchGroup {
    var count: Int {
        debugDescription.components(separatedBy: ",").filter { $0.contains("count") }.first?.components(separatedBy: CharacterSet.decimalDigits.inverted).compactMap { Int($0) }.first ?? 0
    }
}

#Preview("Small Screen") {
    RootView {
        ContentView()
    }
    .frame(width: 500)
    .frame(height: 1200)
}

#Preview("Big Screen") {
    RootView {
        ContentView()
    }
    .frame(width: 1200)
    .frame(height: 1200)
}
