import CryptoKit
import Foundation
import OSLog
import SwiftData

extension DB {
    var labelForGroup: String { "\(self.label)🌾🌾🌾" }

    func updateGroupForMetas(_ metas: DiskFileGroup, verbose: Bool = false) {
        let title = "\(labelForGroup) UpdateGroup(\(metas.count))"
        let startTime = DispatchTime.now()
        
        os_log("\(title)🚀🚀🚀")

        let total = metas.count
        let context = ModelContext(modelContainer)
        context.autosaveEnabled = false

        for (i,meta) in metas.files.enumerated() {
            if verbose && i%100 == 0 {
                os_log("\(Logger.isMain)\(Self.label)UpdateGroup \(i)/\(total)")
            }
            
            guard meta.isDownloaded, let audio = Self.findAudio(context: context, meta.url) else {
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
        
        os_log("\(self.jobEnd(startTime, title: title))")
    }
    
//    func runFindAudioGroupJob() {
//        runJob(
//            "GetGroup 🌾🌾🌾",
//            verbose: true,
//            descriptor: Audio.descriptorNoGroup,
//            printLog: true,
//            printStartLog: true,
//            printQueueEnter: true,
//            printLogStep: 100,
//            printCost: true,
//            concurrency: false,
//            code: { audio, onEnd in
//                self.updateGroup(audio)
//
//                onEnd()
//            })
//    }
}
