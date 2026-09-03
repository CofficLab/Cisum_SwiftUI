import CisumUIComponents
import SwiftData
import SwiftUI

public struct AudioLikeSettingsView: View, SuperLog {
    public nonisolated static var emoji: String { "⚙️❤️" }

    @ObservedObject private var viewModel: AudioLikeViewModel

    init(viewModel: AudioLikeViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Liked audio", bundle: .module)
                .font(.headline)

            if viewModel.isLoading {
                ProgressView {
                    Text("Loading...", bundle: .module)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.likedAudios.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "heart.slash")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No liked audio yet", bundle: .module)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.likedAudios, id: \.audioId) { audio in
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
            viewModel.reloadLikedAudios()
        }
    }
}
