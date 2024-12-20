import MagicKit
import OSLog
import SwiftUI

struct AudioTile: View {
    @EnvironmentObject private var playMan: PlayMan

    let asset: PlayAsset

    init(asset: PlayAsset) {
        self.asset = asset
    }

    var body: some View {
        HStack {
            HStack {
                AudioAvatar(asset).frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 0) {
                    Text(asset.fileName)

                    HStack {
                        Text(asset.getFileSizeReadable())
//                        if audio.like {
//                            Image(systemName: "star.fill")
//                        }
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
