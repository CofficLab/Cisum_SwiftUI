import Foundation
import OSLog
import SwiftUI

/// 内容相同的Audio的集合
struct AudioGroup {
    static var label = "🍊 AudioGroup::"

    var hash: String?
    var audios: [Audio]

    var audio: Audio { audios.first! }
    var count: Int { audios.count }
    var label: String { AudioGroup.label }

    static func fromAudios(_ audios: [Audio]) -> [Self] {
        os_log("\(self.label)FromAudios, total=\(audios.count)")

        let d = Dictionary(grouping: audios, by: {
            $0.getHash()
        })

        return d.map { key, value in
            AudioGroup(hash: key, audios: value.sorted { $0.order < $1.order })
        }.sorted { $0.hash ?? "" < $1.hash ?? "" }
    }
}

extension AudioGroup: Identifiable {
    var id: String { hash ?? UUID().uuidString }
}

#Preview("App") {
    AppPreview()
}
