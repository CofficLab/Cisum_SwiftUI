import MagicKit
import MagicAlert
import MagicPlayMan
import OSLog
import PluginAudio
import PluginBook
import SwiftData
import SwiftUI

enum BookGridUpdatePolicy {
    static func shouldApplyResult(currentGeneration: Int, resultGeneration: Int) -> Bool {
        currentGeneration == resultGeneration
    }

    static func nextGeneration(after generation: Int) -> Int {
        generation + 1
    }
}

enum BookGridPlaybackRequestPolicy {
    static func shouldApplyResult(
        currentGeneration: Int,
        resultGeneration: Int,
        requestedBookURL: URL,
        selectedBookURL: URL?,
        displayedBooks: [BookDTO]
    ) -> Bool {
        currentGeneration == resultGeneration
            && BookGridSelectionPolicy.representsSelectedBook(requestedBookURL, selectedURL: selectedBookURL)
            && BookGridSelectionPolicy.containsSelectedBook(requestedBookURL, in: displayedBooks)
    }

    static func shouldReportNoPlayableChapters(
        currentGeneration: Int,
        resultGeneration: Int,
        requestedBookURL: URL,
        selectedBookURL: URL?,
        displayedBooks: [BookDTO]
    ) -> Bool {
        shouldApplyResult(
            currentGeneration: currentGeneration,
            resultGeneration: resultGeneration,
            requestedBookURL: requestedBookURL,
            selectedBookURL: selectedBookURL,
            displayedBooks: displayedBooks
        )
    }

    static func generationAfterInvalidatingPendingPlayback(_ generation: Int) -> Int {
        generation + 1
    }
}

enum BookGridSelectionPolicy {
    static func representsSelectedBook(_ bookURL: URL, selectedURL: URL?) -> Bool {
        guard let selectedURL else { return false }
        return BookPlaybackOrdering.representsSameFile(bookURL, selectedURL)
    }

    static func containsSelectedBook(_ selectedURL: URL, in books: [BookDTO]) -> Bool {
        books.contains {
            representsSelectedBook($0.url, selectedURL: selectedURL)
        }
    }

    static func selectionLabel(bookTitle: String) -> String {
        String(localized: "Select \(bookTitle)", bundle: .module)
    }
}

enum BookGridPlayableChildrenLoader {
    static func load(for bookURL: URL) async -> [URL] {
        await Task.detached(priority: .userInitiated) {
            BookPlaybackOrdering.playableChildren(for: bookURL)
        }.value
    }
}

enum BookDBViewBookStateLookup {
    static func findBookState(for bookURL: URL, in context: ModelContext) throws -> BookState? {
        let descriptor = BookState.descriptorOf(bookURL)
        if let state = try context.fetch(descriptor).first {
            return state
        }

        return try context.fetch(BookState.descriptorAll).first { state in
            BookState.representsSameBookURL(state.url, as: bookURL)
        }
    }
}

struct BookGrid: View, SuperLog, SuperThread, SuperEvent {
    nonisolated static let emoji = "📖"
    nonisolated static let verbose = false

    @Environment(\.bookDBViewDependencies) private var dependencies
    @EnvironmentObject var man: MagicPlayMan
    @EnvironmentObject var repo: BookRepo

    @State var selection: AudioModel? = nil
    @State var syncingTotal: Int = 0
    @State var syncingCurrent: Int = 0
    
    /// Currently selected book URL.
    @State private var selectedBookURL: URL? = nil
    
    /// Book collection list containing folder-style books.
    @State private var books: [BookDTO] = []
    
    /// Whether books are loading.
    @State private var isLoading: Bool = true
    
    /// Whether data is syncing.
    @State private var isSyncing: Bool = false
    
    /// Debounced update task.
    @State private var updateBooksDebounceTask: Task<Void, Never>? = nil

    /// Current book list loading generation used to discard stale background refresh results.
    @State private var updateBooksGeneration: Int = 0

    /// Current book tap playback generation used to discard stale progress lookup results.
    @State private var playBookGeneration: Int = 0

    /// Total book count.
    var total: Int { books.count }

    /// Finds the book state.
    private func findBookState(_ bookURL: URL, in container: ModelContainer) async -> BookState? {
        let context = ModelContext(container)
        do {
            return try BookDBViewBookStateLookup.findBookState(for: bookURL, in: context)
        } catch {
            if Self.verbose {
                os_log("\(self.t)⚠️ Failed to query book state: \(error.localizedDescription)")
            }
            return nil
        }
    }

    /// Whether tips should be shown.
    var showTips: Bool {
        false
    }

    var body: some View {
        if Self.verbose {
            os_log("\(self.t)📺 Rendering")
        }
        return Group {
            if isLoading {
                BookDBTips(variant: .loading)
            } else if total == 0 {
                BookDBTips(variant: .empty)
            } else {
                VStack(spacing: 0) {
                    HStack {
                        Text("Total \(total)", bundle: .module)
                        Spacer()
                        if isSyncing {
                            HStack(spacing: 6) {
                                ProgressView()
                                    .controlSize(.small)
                                Text("Reading repository", bundle: .module)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                    
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 150), spacing: 12),
                        ], alignment: .center, spacing: 16, pinnedViews: [.sectionHeaders]) {
                            ForEach(books) { item in
                                BookTile(url: item.url, title: item.bookTitle, childCount: item.childCount)
                                    .overlay(
                                        // Highlight border.
                                        Rectangle()
                                            .stroke(
                                                BookGridSelectionPolicy.representsSelectedBook(
                                                    item.url,
                                                    selectedURL: selectedBookURL
                                                ) ? Color.accentColor : Color.clear,
                                                lineWidth: BookGridSelectionPolicy.representsSelectedBook(
                                                    item.url,
                                                    selectedURL: selectedBookURL
                                                ) ? 3 : 0
                                            )
                                    )
                                    .animation(.easeInOut(duration: 0.2), value: selectedBookURL)
                                    .onTapGesture {
                                        handleBookTap(book: item)
                                    }
                                    .accessibilityElement(children: .combine)
                                    .accessibilityLabel(BookGridSelectionPolicy.selectionLabel(bookTitle: item.bookTitle))
                                    .accessibilityAddTraits(.isButton)
                                    .accessibilityAction {
                                        handleBookTap(book: item)
                                    }
                                    .help(BookGridSelectionPolicy.selectionLabel(bookTitle: item.bookTitle))
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear(perform: handleOnAppear)
        .onPlayManAssetChanged(handleAssetChanged)
        .onBookDBDeleted(perform: handleBookDBDeleted)
        .onBookDBSynced(perform: handleBookDBSynced)
        .onBookDBSortDone(perform: handleBookDBSortDone)
        .onBookDBUpdated(perform: handleBookDBUpdated)
        .onBookDBSyncing(perform: handleBookDBSyncing)
        .onDisappear(perform: handleOnDisappear)
    }
}

// MARK: - Action

extension BookGrid {
    /// Updates the book list.
    ///
    /// Asynchronously fetches all book data from the repository and updates the UI.
    /// Only collection books (folders) are fetched and sorted in order.
    /// Runs at background priority to avoid blocking the main thread.
    private func updateBooks(generation: Int) {
        let currentRepo = self.repo

        Task.detached(priority: .background) {
            if Self.verbose {
                os_log("\(self.t)🔄 Fetching book list")
            }
            
            let books = await currentRepo.getAll(reason: self.className)
            
            if Self.verbose {
                os_log("\(self.t)✅ Fetched \(books.count) books")
            }

            await self.setBooks(books, generation: generation)
        }
    }

    /// Schedules a debounced update.
    ///
    /// Delays book list updates with debounce to avoid frequent refreshes.
    /// If called again during the delay, the previous task is canceled and the timer restarts.
    ///
    /// - Parameter seconds: Delay in seconds, defaulting to 0.25 seconds.
    @MainActor
    private func scheduleUpdateBooksDebounced(delay seconds: Double = 0.25) {
        if Self.verbose {
            os_log("\(self.t)⏱️ Scheduling debounced update after \(seconds) seconds")
        }
        
        updateBooksDebounceTask?.cancel()
        updateBooksGeneration = BookGridUpdatePolicy.nextGeneration(after: updateBooksGeneration)
        let generation = updateBooksGeneration
        updateBooksDebounceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1000000000))
            guard !Task.isCancelled else { return }
            self.updateBooks(generation: generation)
        }
    }
    
    /// Updates the selected book.
    ///
    /// Finds and highlights the book that contains the given audio URL.
    /// If the URL is the book itself or one of its child files, it is recognized and selected.
    ///
    /// - Parameter url: Audio file URL to look up.
    private func updateSelectedBook(for url: URL) {
        if Self.verbose {
            os_log("\(self.t)🔍 Finding book containing audio: \(url.lastPathComponent)")
        }
        
        // Find the book that contains this URL.
        for book in books {
            if BookPlaybackOrdering.representsSameFile(book.url, url)
                || BookPlaybackOrdering.containsPlayableChild(url, in: book.url) {
                if Self.verbose {
                    os_log("\(self.t)✅ Found book: \(book.bookTitle)")
                }
                selectedBookURL = book.url
                return
            }
        }
        
        if Self.verbose {
            os_log("\(self.t)⚠️ No matching book found")
        }
        selectedBookURL = nil
    }

    private func isPlayableSavedURL(_ savedURL: URL, in book: BookDTO, playableChildren: [URL]) -> Bool {
        if BookPlaybackOrdering.representsSameFile(book.url, savedURL) {
            return FileManager.default.fileExists(atPath: savedURL.path)
                && BookPluginInfo.supportedExtensions.contains(savedURL.pathExtension.lowercased())
        }

        return BookPlaybackOrdering.contains(savedURL, in: playableChildren)
    }

    private func play(_ url: URL, in book: BookDTO, at time: TimeInterval?, generation: Int, reason: String) async {
        guard BookGridPlaybackRequestPolicy.shouldApplyResult(
            currentGeneration: playBookGeneration,
            resultGeneration: generation,
            requestedBookURL: book.url,
            selectedBookURL: selectedBookURL,
            displayedBooks: books
        ) else {
            return
        }

        await man.play(url, autoPlay: false, startTime: time, reason: reason)
    }
    
    /// Plays a book.
    ///
    /// Triggered when a book is tapped. Prefer saved playback progress.
    /// If no saved state exists, playback starts from the beginning.
    ///
    /// - Parameter book: Book DTO to play.
    private func playBook(_ book: BookDTO, generation: Int) async {
        if Self.verbose {
            os_log("\(self.t)▶️ Preparing to play book: \(book.bookTitle)")
        }

        let playableChildren = await BookGridPlayableChildrenLoader.load(for: book.url)
        let reason = self.className

        // First try to restore this book's progress from BookState.
        do {
            let container = try BookConfig.getContainer(dbRootURL: dependencies.dbRoot)
            if let bookState = await findBookState(book.url, in: container),
               let savedURL = bookState.currentURL,
               let savedTime = bookState.time,
               isPlayableSavedURL(savedURL, in: book, playableChildren: playableChildren) {
                // This book has saved progress, so resume playback.
                if Self.verbose {
                    os_log("\(self.t)📖 Resuming book progress: \(savedURL.lastPathComponent) @ \(savedTime)s")
                }
                await play(savedURL, in: book, at: savedTime, generation: generation, reason: reason)
                return
            }
        } catch {
            if Self.verbose {
                os_log("\(self.t)⚠️ Unable to access book database: \(error.localizedDescription)")
            }
        }

        // Then check whether the global state belongs to this book.
        if let savedURL = BookSettingRepo.getCurrent(),
           let savedTime = BookSettingRepo.getCurrentTime(),
           isPlayableSavedURL(savedURL, in: book, playableChildren: playableChildren) {
            // The saved URL belongs to this book, so resume playback.
            if Self.verbose {
                os_log("\(self.t)📖 Resuming from global state: \(savedURL.lastPathComponent) @ \(savedTime)s")
            }
            await play(savedURL, in: book, at: savedTime, generation: generation, reason: reason)
            return
        }

        // No saved state, start from the beginning.
        if let first = playableChildren.first {
            if Self.verbose {
                os_log("\(self.t)🎵 Playing first child from the beginning: \(first.lastPathComponent)")
            }
            guard BookGridPlaybackRequestPolicy.shouldApplyResult(
                currentGeneration: playBookGeneration,
                resultGeneration: generation,
                requestedBookURL: book.url,
                selectedBookURL: selectedBookURL,
                displayedBooks: books
            ) else {
                return
            }
            await man.play(first, reason: reason)
        } else {
            guard BookGridPlaybackRequestPolicy.shouldReportNoPlayableChapters(
                currentGeneration: playBookGeneration,
                resultGeneration: generation,
                requestedBookURL: book.url,
                selectedBookURL: selectedBookURL,
                displayedBooks: books
            ) else {
                return
            }

            guard FileManager.default.fileExists(atPath: book.url.path),
                  BookPluginInfo.supportedExtensions.contains(book.url.pathExtension.lowercased()) else {
                if Self.verbose {
                    os_log("\(self.t)⚠️ No playable chapters: \(book.bookTitle)")
                }
                alert_error(String(localized: "No playable chapters found", bundle: .module))
                return
            }

            await man.play(book.url, reason: reason)
        }
    }
}

// MARK: - Setter

extension BookGrid {
    /// Sets the book list.
    ///
    /// Updates the book list and ends the loading state.
    /// If the currently selected book is not in the new list, selection is cleared automatically.
    ///
    /// - Parameter newValue: New book DTO list.
    @MainActor
    private func setBooks(_ newValue: [BookDTO], generation: Int) {
        guard BookGridUpdatePolicy.shouldApplyResult(
            currentGeneration: updateBooksGeneration,
            resultGeneration: generation
        ) else {
            return
        }

        if Self.verbose {
            os_log("\(self.t)📋 Setting book list, count: \(newValue.count)")
        }
        
        books = newValue
        self.setIsLoading(false)

        // Restore selection from the current playback item after data loads to avoid losing highlight during the empty-list phase.
        if let currentAsset = man.asset {
            updateSelectedBook(for: currentAsset)
        } else if let currentSelection = selectedBookURL,
                  !BookGridSelectionPolicy.containsSelectedBook(currentSelection, in: newValue) {
            if Self.verbose {
                os_log("\(self.t)⚠️ Selected book is not in the list, clearing selection")
            }
            selectedBookURL = nil
        }
    }

    /// Sets the loading state.
    ///
    /// - Parameter newValue: Whether loading is active.
    private func setIsLoading(_ newValue: Bool) {
        if Self.verbose {
            os_log("\(self.t)⏳ Loading state: \(newValue ? "loading" : "done")")
        }
        isLoading = newValue
    }

    /// Sets the sync state.
    ///
    /// - Parameter newValue: Whether syncing is active.
    private func setIsSyncing(_ newValue: Bool) {
        if Self.verbose {
            os_log("\(self.t)🔄 Sync state: \(newValue ? "syncing" : "done")")
        }
        isSyncing = newValue
    }
}

// MARK: - Event Handler

extension BookGrid {
    /// Handles view appearance.
    ///
    /// Starts loading the book list when the view first appears.
    /// If the player has current audio, the matching book is selected automatically.
    func handleOnAppear() {
        if Self.verbose {
            os_log("\(self.t)👀 View appeared")
        }
        
        setIsLoading(true)
        scheduleUpdateBooksDebounced()
        
        // Check the currently playing audio during initialization.
        if let currentAsset = man.asset {
            if Self.verbose {
                os_log("\(self.t)🎵 Current playback detected: \(currentAsset.lastPathComponent)")
            }
            updateSelectedBook(for: currentAsset)
        }
    }
    
    /// Handles book taps.
    ///
    /// Triggered when the user taps a book card. Updates selection and starts playback.
    ///
    /// - Parameter book: Tapped book DTO.
    func handleBookTap(book: BookDTO) {
        if Self.verbose {
            os_log("\(self.t)👆 Book tapped: \(book.bookTitle)")
        }
        
        selectedBookURL = book.url
        playBookGeneration += 1
        let generation = playBookGeneration
        
        Task {
            await playBook(book, generation: generation)
        }
    }
    
    /// Handles playback asset changes.
    ///
    /// Triggered when the player's playback asset changes, then updates the selected book highlight.
    ///
    /// - Parameter url: New playback asset URL. When nil, selection is cleared.
    func handleAssetChanged(_ url: URL?) {
        if Self.verbose {
            if let url = url {
                os_log("\(self.t)🔄 Playback asset changed: \(url.lastPathComponent)")
            } else {
                os_log("\(self.t)🔄 Playback stopped")
            }
        }
        
        if let url = url {
            updateSelectedBook(for: url)
        } else {
            selectedBookURL = nil
            playBookGeneration = BookGridPlaybackRequestPolicy.generationAfterInvalidatingPendingPlayback(playBookGeneration)
        }
    }
    
    /// Handles book deletion.
    ///
    /// Triggered when a book is deleted, then refreshes the book list.
    ///
    /// - Parameter notification: Deletion completion notification.
    func handleBookDBDeleted(_ notification: Notification) {
        if Self.verbose {
            os_log("\(self.t)🗑️ Book deleted")
        }
        playBookGeneration = BookGridPlaybackRequestPolicy.generationAfterInvalidatingPendingPlayback(playBookGeneration)
        scheduleUpdateBooksDebounced()
    }
    
    /// Handles data sync completion.
    ///
    /// Triggered when database sync completes, then refreshes the book list and ends the sync state.
    ///
    /// - Parameter notification: Sync completion notification.
    func handleBookDBSynced(_ notification: Notification) {
        if Self.verbose {
            os_log("\(self.t)✅ Data sync finished")
        }
        playBookGeneration = BookGridPlaybackRequestPolicy.generationAfterInvalidatingPendingPlayback(playBookGeneration)
        scheduleUpdateBooksDebounced()
        setIsSyncing(false)
    }
    
    /// Handles sort completion.
    ///
    /// Triggered when database sorting completes, then refreshes the book list.
    ///
    /// - Parameter notification: Sort completion notification.
    func handleBookDBSortDone(_ notification: Notification) {
        if Self.verbose {
            os_log("\(self.t)✅ Sorting finished")
        }
        playBookGeneration = BookGridPlaybackRequestPolicy.generationAfterInvalidatingPendingPlayback(playBookGeneration)
        scheduleUpdateBooksDebounced()
    }
    
    /// Handles data updates.
    ///
    /// Triggered when book data changes, then refreshes the book list.
    ///
    /// - Parameter notification: Update completion notification.
    func handleBookDBUpdated(_ notification: Notification) {
        if Self.verbose {
            os_log("\(self.t)🔄 Data updated")
        }
        playBookGeneration = BookGridPlaybackRequestPolicy.generationAfterInvalidatingPendingPlayback(playBookGeneration)
        scheduleUpdateBooksDebounced()
    }
    
    /// Handles data sync start.
    ///
    /// Triggered when database sync starts, then shows the sync state.
    ///
    /// - Parameter notification: Sync start notification.
    func handleBookDBSyncing(_ notification: Notification) {
        if Self.verbose {
            os_log("\(self.t)🔄 Starting data sync")
        }
        setIsSyncing(true)
    }
    
    /// Handles view disappearance.
    ///
    /// Triggered when the view disappears, then cancels pending debounce tasks.
    func handleOnDisappear() {
        if Self.verbose {
            os_log("\(self.t)👋 View disappeared")
        }
        
        updateBooksDebounceTask?.cancel()
        updateBooksDebounceTask = nil
        updateBooksGeneration += 1
        playBookGeneration = BookGridPlaybackRequestPolicy.generationAfterInvalidatingPendingPlayback(playBookGeneration)
    }
}

// MARK: - Preview

#if os(macOS)

#endif
