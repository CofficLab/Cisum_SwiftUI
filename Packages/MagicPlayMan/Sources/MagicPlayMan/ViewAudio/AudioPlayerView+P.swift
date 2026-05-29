import MagicKit
import OSLog
import SwiftUI

struct AudioPlayerViewShowcase: View {
    var body: some View {
        TabView {
            // 基本用法
            VStack(spacing: 12) {
                Text("基本用法")
                    .font(.headline)
                    .padding(.top)

                AudioPlayerView(
                    title: "Test Song",
                    artist: "Test Artist",
                    url: .documentsDirectory
                )
                .frame(width: 400)
            }
            .tabItem {
                Label("基本", systemImage: "music.note")
            }

            // 带默认封面
            VStack(spacing: 12) {
                Text("带默认封面")
                    .font(.headline)
                    .padding(.top)

                AudioPlayerView(
                    title: "Song with Cover",
                    artist: "Artist Name",
                    url: .documentsDirectory,
                    defaultArtwork: Image(systemName: "photo.artframe")
                )
                .frame(width: 400)

                Text("使用 defaultArtwork 参数")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .tabItem {
                Label("默认封面", systemImage: "photo.artframe")
            }

            // 无艺术家信息
            VStack(spacing: 12) {
                Text("无艺术家信息")
                    .font(.headline)
                    .padding(.top)

                AudioPlayerView(
                    title: "Unknown Artist Song",
                    url: .documentsDirectory,
                    defaultArtwork: Image(systemName: "music.note")
                )
                .frame(width: 400)

                Text("artist 参数为 nil")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .tabItem {
                Label("无艺术家", systemImage: "person.slash")
            }

            // 无 URL
            VStack(spacing: 12) {
                Text("无 URL（空状态）")
                    .font(.headline)
                    .padding(.top)

                AudioPlayerView(
                    title: "No Media",
                    artist: "Select media to play",
                    url: nil,
                    defaultArtwork: Image(systemName: "doc.questionmark")
                )
                .frame(width: 400)

                Text("url 参数为 nil")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .tabItem {
                Label("空状态", systemImage: "doc.questionmark")
            }
        }
        .frame(width: 500, height: 600)
    }
}

#Preview("AudioPlayerView Showcase") {
    AudioPlayerViewShowcase()
}
