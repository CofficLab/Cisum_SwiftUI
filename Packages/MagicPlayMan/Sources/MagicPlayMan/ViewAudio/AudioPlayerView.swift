import MagicKit
import OSLog
import SwiftUI

struct AudioPlayerView: View, SuperLog {
    nonisolated static let emoji = "🖥️"

    let title: String
    let artist: String?
    let url: URL?
    let defaultArtwork: Image?
    let defaultArtworkBuilder: (() -> any View)?

    init(title: String, artist: String? = nil, url: URL? = nil, defaultArtwork: Image? = nil, defaultArtworkBuilder: (() -> any View)? = nil) {
        self.title = title
        self.artist = artist
        self.url = url
        self.defaultArtwork = defaultArtwork
        self.defaultArtworkBuilder = defaultArtworkBuilder
    }

    var body: some View {
        VStack(spacing: 20) {
            url?.makeAvatarView()
                .id(url)  // Force view refresh on URL change
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(20)

            // 标题和艺术家
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)

                if let artist = artist {
                    Text(artist)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(.bottom, 20)
        }
    }
}

#Preview("AudioPlayerView Showcase") {
    AudioPlayerViewShowcase()
}

