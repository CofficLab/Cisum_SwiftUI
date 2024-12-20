import MagicKit
import OSLog
import SwiftUI

struct AudioTile: View {
    @EnvironmentObject private var playMan: PlayMan

    let audio: AudioModel
    let asset: PlayAsset

    init(audio: AudioModel) {
        self.audio = audio
        self.asset = audio.toPlayAsset()
    }

    var body: some View {
        HStack {
            HStack {
                AudioAvatar(asset).frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 0) {
                    Text(audio.fileName)

                    HStack {
                        Text(audio.getFileSizeReadable())
                        if audio.like {
                            Image(systemName: "star.fill")
                        }
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
    }
}

// 使用 equatable 减少不必要的重绘
extension AudioTile: Equatable {
    static func == (lhs: AudioTile, rhs: AudioTile) -> Bool {
        lhs.audio.url == rhs.audio.url
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
