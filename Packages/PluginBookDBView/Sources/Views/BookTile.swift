import CisumUIComponents
import OSLog
import PluginBook
import SwiftData
import SwiftUI

struct BookTileLoadIdentity: Equatable {
    let bookURL: URL
    let dbRoot: URL
    let stateRevision: Int
}

enum BookTileStateRefreshPolicy {
    static func shouldReloadTile(bookURL: URL, updatedBookURL: URL?) -> Bool {
        guard let updatedBookURL else { return false }
        return BookPlaybackOrdering.representsSameFile(bookURL, updatedBookURL)
    }

    static func nextRevision(after revision: Int) -> Int {
        revision + 1
    }
}

/**
 * Purpose: display book data read from the database as a tile with cover art and basic information.
 * Properties:
 *   - url: book URL path
 *   - title: book title
 *   - childCount: number of audio files contained in the book
 *   - cover: book cover image loaded asynchronously
 *   - state: playback state that records the last playback position
 * Usage: shown in the book list with cover art, title, file count, and playback history.
 */
struct BookTile: View, SuperThread, SuperLog, Equatable {
    nonisolated static func == (lhs: BookTile, rhs: BookTile) -> Bool {
        lhs.url == rhs.url
    }

    @EnvironmentObject var viewModel: BookGridViewModel
    @Environment(\.bookDBViewDependencies) private var dependencies
    @LumiTheme private var appTheme

    @State private var lastPlayedTitle: String? = nil
    @State private var cover: Image? = nil
    @State private var tileSize: CGSize = .init(width: 150, height: 200)
    @State private var stateRevision: Int = 0

    nonisolated static let emoji = "🖥️"
    private let verbose = false
    
    private var hasCover: Bool { cover != nil }
    private var noCover: Bool { cover == nil }
    
    var url: URL
    var title: String
    var childCount: Int

    var body: some View {
        ZStack {
            if let cover = cover {
                cover
                    .resizable()
                    .scaledToFill()
                    .frame(width: tileSize.width, height: tileSize.height)
                    .clipped()
            } else {
                appTheme.elevatedSurface
            }

            HStack {
                Spacer()
                VStack {
                    Spacer()

                    if noCover {
                        Text(title)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .minimumScaleFactor(0.7)
                            .padding(.horizontal, 10)
                    }

                    Spacer()

                    if childCount > 0, noCover {
                        Text("Total \(childCount)", bundle: .module)
                    }

                    Spacer()
                    if let lastPlayedTitle, noCover {
                        VStack(spacing: 0) {
                            HStack {
                                Image(systemName: "info")
                                Text("Last played", bundle: .module)
                            }
                            Text(lastPlayedTitle)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .minimumScaleFactor(0.75)
                        }
                        .font(.footnote)
                        .padding()
                    }
                }
                Spacer()
            }
        }
        .frame(width: tileSize.width)
        .frame(height: tileSize.height)
        .task(id: BookTileLoadIdentity(bookURL: url, dbRoot: dependencies.dbRoot, stateRevision: stateRevision)) {
            await loadTileData()
        }
        .onChange(of: viewModel.lastStateUpdatedURL) { _, updatedURL in
            guard BookTileStateRefreshPolicy.shouldReloadTile(bookURL: url, updatedBookURL: updatedURL) else {
                return
            }
            stateRevision = BookTileStateRefreshPolicy.nextRevision(after: stateRevision)
        }
    }
}

// MARK: - Action

extension BookTile {
    @MainActor
    func loadTileData() async {
        cover = nil
        lastPlayedTitle = nil

        guard let repo = await dependencies.bookRepo() else { return }

        let bookURL = url
        let bookTitle = title
        let thumbnailSize = tileSize
        let dbRoot = dependencies.dbRoot
        let logPrefix = t

        if verbose {
            os_log("\(logPrefix)Loading cover art for \(bookTitle)")
        }

        async let loadedCover = repo.getCover(for: bookURL, thumbnailSize: thumbnailSize)
        async let loadedLastPlayedTitle = Self.lastPlayedTitle(for: bookURL, dbRoot: dbRoot, logPrefix: logPrefix, verbose: verbose)
        let (newCover, newLastPlayedTitle) = await (loadedCover, loadedLastPlayedTitle)

        guard !Task.isCancelled else {
            return
        }

        cover = newCover
        lastPlayedTitle = newLastPlayedTitle
    }

    nonisolated private static func lastPlayedTitle(
        for bookURL: URL,
        dbRoot: URL,
        logPrefix: String,
        verbose: Bool
    ) async -> String? {
        await Task.detached(priority: .background) {
            do {
                let container = try BookConfig.getContainer(dbRootURL: dbRoot)
                let context = ModelContext(container)
                let state = try BookDBViewBookStateLookup.findBookState(for: bookURL, in: context)
                return state?.currentURL?.lastPathComponent
            } catch {
                if verbose {
                    os_log(.error, "\(logPrefix)Failed to read book playback state: \(error.localizedDescription)")
                }

                return nil
            }
        }.value
    }
}

// MARK: - Preview

#if os(macOS)

#endif
