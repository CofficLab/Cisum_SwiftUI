import CisumUIComponents
import SwiftUI

public struct BookLikeSettingsView: View, SuperLog {
    public nonisolated static var emoji: String { "❤️" }
    private static var verbose: Bool { false }

    @State private var likedBooks: [BookLikeItem] = []
    @State private var isLoading = true

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Liked Books", bundle: .module)
                .font(.headline)

            if isLoading {
                ProgressView {
                    Text(Self.loadingText)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if likedBooks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "heart.slash")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No liked books yet", bundle: .module)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(likedBooks) { book in
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
            loadLikedBooks()
        }
        .onReceive(NotificationCenter.default.publisher(for: .BookLikeStatusChanged)) { _ in
            loadLikedBooks()
        }
    }

    private func loadLikedBooks() {
        likedBooks = BookLikeStore.likedBooks()
        isLoading = false
    }
}

extension BookLikeSettingsView {
    nonisolated static var loadingTextKey: String { "Loading..." }

    private static var loadingText: String {
        String(localized: String.LocalizationValue(loadingTextKey), bundle: .module)
    }
}
