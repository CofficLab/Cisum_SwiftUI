import MagicKit
import SwiftData
import SwiftUI

struct AudioLikeSettingsLoadPolicy {
    static func shouldApplyResult(currentGeneration: Int, resultGeneration: Int) -> Bool {
        resultGeneration == currentGeneration
    }
}

public struct AudioLikeSettingsView: View, SuperLog {
    public nonisolated static var emoji: String { "⚙️❤️" }
    private let verbose = false

    @State private var likedAudios: [AudioLikeModel] = []
    @State private var isLoading = true
    @State private var loadGeneration = 0

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Liked audio", bundle: .module)
                .font(.headline)

            if isLoading {
                ProgressView {
                    Text("Loading...", bundle: .module)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if likedAudios.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "heart.slash")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No liked audio yet", bundle: .module)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(likedAudios, id: \.audioId) { audio in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(audio.title ?? audio.url?.lastPathComponent ?? String(localized: "Unknown audio", bundle: .module))
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
        .onReceive(NotificationCenter.default.publisher(for: .AudioLikeStatusChanged)) { _ in
            loadLikedAudios()
        }
    }

    private func loadLikedAudios() {
        loadGeneration += 1
        let generation = loadGeneration

        Task {
            let audios = await AudioLikeRepo.shared.getAllLiked()
            await MainActor.run {
                guard AudioLikeSettingsLoadPolicy.shouldApplyResult(
                    currentGeneration: self.loadGeneration,
                    resultGeneration: generation
                ) else { return }

                self.likedAudios = audios
                self.isLoading = false
            }
        }
    }
}
