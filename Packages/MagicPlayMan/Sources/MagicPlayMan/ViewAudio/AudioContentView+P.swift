import MagicKit
import SwiftUI

struct AudioContentViewShowcase: View {
    var body: some View {
        TabView {
            // 基本用法 - Verbose
            VStack(spacing: 12) {
                Text("基本用法 (Verbose)")
                    .font(.headline)
                    .padding(.top)

                AudioContentView(
                    asset: .init(
                        url: .documentsDirectory,
                        metadata: .init(
                            title: "Test Song",
                            artist: "Test Artist",
                            album: "Test Album"
                        )
                    ),
                    verbose: true
                )
                .frame(width: 400)
            }
            .tabItem {
                Label("Verbose", systemImage: "speaker.wave.2")
            }

            // 基本用法 - Non-Verbose
            VStack(spacing: 12) {
                Text("基本用法 (Non-Verbose)")
                    .font(.headline)
                    .padding(.top)

                AudioContentView(
                    asset: .init(
                        url: .documentsDirectory,
                        metadata: .init(
                            title: "Test Song",
                            artist: "Test Artist",
                            album: "Test Album"
                        )
                    ),
                    verbose: false
                )
                .frame(width: 400)
            }
            .tabItem {
                Label("Quiet", systemImage: "speaker.slash")
            }

            // 外部传入 Artwork
            VStack(spacing: 12) {
                Text("外部传入 Artwork")
                    .font(.headline)
                    .padding(.top)

                AudioContentView(
                    asset: .init(
                        url: .documentsDirectory,
                        metadata: .init(
                            title: "Song with Cover",
                            artist: "Artist Name",
                            album: "Album Name"
                        )
                    ),
                    artwork: Image(systemName: "music.note"),
                    verbose: false
                )
                .frame(width: 400)

                Text("使用 artwork 参数传入自定义封面图")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
            .tabItem {
                Label("外部封面", systemImage: "photo")
            }

            // 默认封面图
            VStack(spacing: 12) {
                Text("默认封面图")
                    .font(.headline)
                    .padding(.top)

                AudioContentView(
                    asset: .init(
                        url: .documentsDirectory,
                        metadata: .init(
                            title: "Song with Default Cover",
                            artist: "Artist Name",
                            album: "Album Name"
                        )
                    ),
                    defaultArtwork: Image(systemName: "photo.artframe"),
                    verbose: false
                )
                .frame(width: 400)

                Text("使用 defaultArtwork 参数设置默认封面")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
            .tabItem {
                Label("默认封面", systemImage: "photo.artframe")
            }

            // 同时使用两种封面
            VStack(spacing: 12) {
                Text("优先级：外部 > 本地 > 默认")
                    .font(.headline)
                    .padding(.top)

                AudioContentView(
                    asset: .init(
                        url: .documentsDirectory,
                        metadata: .init(
                            title: "Song with Both Covers",
                            artist: "Artist Name",
                            album: "Album Name"
                        )
                    ),
                    artwork: Image(systemName: "music.note"),
                    defaultArtwork: Image(systemName: "photo.artframe"),
                    verbose: false
                )
                .frame(width: 400)

                Text("外部封面优先级最高，默认封面作为后备")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
            .tabItem {
                Label("优先级", systemImage: "arrow.up.arrow.down")
            }

            // 加载状态
            VStack(spacing: 12) {
                Text("加载状态")
                    .font(.headline)
                    .padding(.top)

                AudioContentView(
                    asset: .init(
                        url: .documentsDirectory,
                        metadata: .init(
                            title: "Loading...",
                            artist: "Unknown Artist",
                            album: "Unknown Album"
                        )
                    ),
                    verbose: false
                )
                .frame(width: 400)

                Text("显示加载指示器")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
            .tabItem {
                Label("加载中", systemImage: "clock")
            }

            // 错误状态
            VStack(spacing: 12) {
                Text("错误状态（无默认封面）")
                    .font(.headline)
                    .padding(.top)

                let errorAsset = MagicAsset(
                    url: URL(string: "invalid://url")!,
                    metadata: .init(
                        title: "Error Test",
                        artist: "Error Artist",
                        album: "Error Album"
                    )
                )

                AudioContentView(asset: errorAsset)
                    .frame(width: 400, height: 500)

                Text("显示错误信息和重试按钮")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
            .tabItem {
                Label("错误", systemImage: "exclamationmark.triangle")
            }

            // 错误状态带默认封面
            VStack(spacing: 12) {
                Text("错误状态（有默认封面）")
                    .font(.headline)
                    .padding(.top)

                let errorAsset = MagicAsset(
                    url: URL(string: "invalid://url")!,
                    metadata: .init(
                        title: "Error with Default",
                        artist: "Error Artist",
                        album: "Error Album"
                    )
                )

                AudioContentView(
                    asset: errorAsset,
                    defaultArtwork: Image(systemName: "exclamationmark.triangle")
                )
                .frame(width: 400, height: 500)

                Text("使用默认封面作为后备方案")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
            .tabItem {
                Label("后备方案", systemImage: "exclamationmark.shield")
            }
        }
        .frame(width: 500, height: 600)
    }
}

#Preview("AudioContentView Showcase") {
    AudioContentViewShowcase()
}
