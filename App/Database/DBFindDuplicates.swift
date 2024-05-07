import Foundation
import OSLog

extension DB {
    func findDuplicatesJob() async {
        var i = 0
        while true {
            if verbose {
                 os_log("\(self.label)检查第 \(i) 个")
            }
            
            if let audio = self.get(i) {
                self.updateDuplicates(audio)
                i += 1
            } else {
                return
            }
        }
    }
    
    private func updateDuplicates(_ audio: Audio) {
        Task(priority: .background) {
            // os_log("\(self.label)检查 -> \(audio.title)")
            let duplicatedOf = self.findDuplicatedOf(audio)
            self.updateDuplicatedOf(audio, duplicatedOf: duplicatedOf?.url)
        }
    }
}
