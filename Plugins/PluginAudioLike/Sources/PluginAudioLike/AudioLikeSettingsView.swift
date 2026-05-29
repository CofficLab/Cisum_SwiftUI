import MagicKit
import SwiftData
import SwiftUI

public struct AudioLikeSettingsView: View, SuperLog {
    public nonisolated static var emoji: String { "⚙️❤️" }
    private let verbose = false

    @State private var likedAudios: [AudioLikeModel] = []
    @State private var isLoading = true

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("喜欢的音频", tableName: "Audio-Like", bundle: .module)
                .font(.headline)

            if isLoading {
                ProgressView {
                    Text("加载中...", tableName: "Audio-Like", bundle: .module)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if likedAudios.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "heart.slash")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("还没有喜欢的音频", tableName: "Audio-Like", bundle: .module)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(likedAudios, id: \.audioId) { audio in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(audio.title ?? audio.url?.lastPathComponent ?? String(localized: "未知音频", table: "Audio-Like", bundle: .module))
                                .font(.body)
                            if let url = audio.url {
                                Text(url.lastPathComponent)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
        }
        .padding()
        .frame(minWidth: 300, minHeight: 400)
        .onAppear {
            loadLikedAudios()
        }
    }

    private func loadLikedAudios() {
        Task {
            let audios = await AudioLikeRepo.shared.getAllLiked()
            await MainActor.run {
                self.likedAudios = audios
                self.isLoading = false
            }
        }
    }
}
