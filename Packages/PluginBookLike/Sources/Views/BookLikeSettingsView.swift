import CisumUIComponents
import SwiftUI

public struct BookLikeSettingsView: View, SuperLog {
    public nonisolated static var emoji: String { "❤️" }
    private static var verbose: Bool { false }

    @ObservedObject private var viewModel: BookLikeViewModel

    init(viewModel: BookLikeViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Liked Books", bundle: .module)
                .font(.headline)

            if viewModel.isLoading {
                ProgressView {
                    Text(Self.loadingText)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.likedBooks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "heart.slash")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No liked books yet", bundle: .module)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.likedBooks) { book in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(book.title)
                                .font(.body)
                            Text(book.url.lastPathComponent)
                                .font(.caption)
                                .foregroundColor(.secondary)
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
            viewModel.handleAppear()
        }
    }
}

extension BookLikeSettingsView {
    nonisolated static var loadingTextKey: String { "Loading..." }

    private static var loadingText: String {
        String(localized: String.LocalizationValue(loadingTextKey), bundle: .module)
    }
}
