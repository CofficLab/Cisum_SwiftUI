import MagicKit
import SwiftUI
import CisumUI

struct AudioContentView: View, SuperLog {
    nonisolated static let emoji = "🎧"
    let asset: MagicAsset
    let artwork: Image? // 允许外部传入缩略图
    let defaultArtwork: Image? // 默认封面图，用于缩略图无法获得时显示
    let defaultArtworkBuilder: (() -> any View)? // 默认封面图构建器
    @State private var localArtwork: Image? // 本地加载的缩略图
    @State private var errorMessage: String?
    let verbose: Bool

    @Environment(\.localization) private var loc

    init(asset: MagicAsset, artwork: Image? = nil, defaultArtwork: Image? = nil, defaultArtworkBuilder: (() -> any View)? = nil, verbose: Bool = true) {
        self.asset = asset
        self.artwork = artwork
        self.defaultArtwork = defaultArtwork
        self.defaultArtworkBuilder = defaultArtworkBuilder
        self.verbose = verbose
    }

    var body: some View {
        VStack(spacing: 30) {
            // 专辑封面
            Group {
                // 优先级: 外部传入 > 本地加载 > 视图构建器 > 默认图片
                if let artwork = artwork ?? localArtwork {
                    artwork
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 300, maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 5)
                } else if let builder = defaultArtworkBuilder {
                    AnyView(builder())
                        .frame(maxWidth: 300, maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 5)
                } else if let defaultImage = defaultArtwork {
                    defaultImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 300, maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 5)
                } else if let error = errorMessage {
                    // 错误状态显示
                    VStack(spacing: 12) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)

                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        // 重试按钮
                        Button {
                            loadArtwork()
                        } label: {
                            Label(loc.retry, systemImage: "arrow.clockwise")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(width: 300, height: 300)
                    .background(Color.primary.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    ProgressView()
                        .frame(width: 300, height: 300)
                }
            }
            .padding()

            // 音频信息
            VStack(spacing: 8) {
                Text(asset.metadata.title)
                    .font(.title2)
                    .bold()

                if let artist = asset.metadata.artist {
                    Text(artist)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                if let album = asset.metadata.album {
                    Text(album)
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
            }
            .multilineTextAlignment(.center)
        }
        .task {
            // 如果没有外部传入的缩略图，则尝试加载
            if artwork == nil {
                loadArtwork()
            }
        }
    }

    private func loadArtwork() {
        // 重置状态
        localArtwork = nil
        errorMessage = nil

        Task {
            do {
                if let thumbnailResult = try await asset.url.thumbnail(size: CGSize(width: 600, height: 600), verbose: self.verbose, reason: "MagicPlayMan." + self.className + ".loadArtwork"),
                   let swiftUIImage = thumbnailResult.toSwiftUIImage() {
                    localArtwork = swiftUIImage
                } else {
                    errorMessage = loc.noArtworkAvailable
                }
            } catch {
                errorMessage = "\(loc.failedToLoadArtwork):\n\(error.localizedDescription)"
            }
        }
    }
}

#Preview("AudioContentView Showcase") {
    AudioContentViewShowcase()
}
