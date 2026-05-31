@testable import PluginBook
import Foundation
import Testing
import SwiftData

@Test func bookPluginInfoExportsMetadata() {
    #expect(BookPluginInfo.dirName == "audios_book")
    #expect(BookPluginInfo.iconName == "book")
    #expect(BookPluginInfo.supportedExtensions.contains("m4b"))
}

@Test func bookPluginSupportsPlayerRecognizedAudiobookExtensions() {
    let playerAudioExtensions = ["mp3", "m4a", "m4b", "aac", "wav", "aiff", "ogg", "opus", "flac", "alac"]

    for extensionName in playerAudioExtensions {
        #expect(BookPluginInfo.supportedExtensions.contains(extensionName))
    }
}

@Test func symlinkedBookFolderIsSupportedLibraryItem() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realBook = root.appendingPathComponent("RealBook", isDirectory: true)
    let linkedBook = root.appendingPathComponent("LinkedBook", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: realBook, withIntermediateDirectories: true)
    try FileManager.default.createSymbolicLink(at: linkedBook, withDestinationURL: realBook)
    try Data("audio".utf8).write(to: realBook.appendingPathComponent("001.m4b"))

    #expect(BookDB.isSupportedBookLibraryItem(linkedBook))
    #expect(BookModel.playableChildCount(for: linkedBook) == 1)
}

@Test func bookModelTreatsSymlinkedBookFolderAsCollection() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realBook = root.appendingPathComponent("RealBook", isDirectory: true)
    let linkedBook = root.appendingPathComponent("LinkedBook", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: realBook, withIntermediateDirectories: true)
    try FileManager.default.createSymbolicLink(at: linkedBook, withDestinationURL: realBook)
    try Data("audio".utf8).write(to: realBook.appendingPathComponent("001.m4b"))

    let book = BookModel(url: linkedBook)

    #expect(book.isCollection)
    #expect(book.childCount == 1)
}

@Test func emptyCloudBookURLIsIgnored() {
    #expect(BookSettingRepo.storedURL(from: "") == nil)
    #expect(BookSettingRepo.storedURL(from: nil) == nil)
    #expect(BookSettingRepo.storedURL(from: "file:///tmp/book/chapter.m4b") == URL(fileURLWithPath: "/tmp/book/chapter.m4b"))
    #expect(BookSettingRepo.storedURL(from: "/tmp/book/legacy-chapter.m4b") == URL(fileURLWithPath: "/tmp/book/legacy-chapter.m4b"))
    #expect(BookSettingRepo.storedURL(from: "not a url") == nil)
}

@Test func localZeroBookTimeOverridesStaleCloudTime() {
    #expect(BookSettingRepo.storedTime(
        localObject: 0.0,
        localDouble: 0,
        cloudString: "42"
    ) == 0)
    #expect(BookSettingRepo.storedTime(
        localObject: nil,
        localDouble: 0,
        cloudString: "42"
    ) == 42)
    #expect(BookSettingRepo.storedTime(
        localObject: nil,
        localDouble: 0,
        cloudString: "not a time"
    ) == nil)
}

@Test func deletedBookFolderContainsNestedRecords() {
    let root = URL(fileURLWithPath: "/tmp/cisum-book-delete-tests", isDirectory: true)
    let book = root.appendingPathComponent("Book", isDirectory: true)
    let nestedChapter = book
        .appendingPathComponent("Disc 1", isDirectory: true)
        .appendingPathComponent("Chapter 1.m4b")
    let siblingBook = root
        .appendingPathComponent("Book Extras", isDirectory: true)
        .appendingPathComponent("Chapter 1.m4b")

    #expect(BookDB.contains(book, bookURL: book))
    #expect(BookDB.contains(book, bookURL: nestedChapter))
    #expect(!BookDB.contains(book, bookURL: siblingBook))
}

@Test func deletedBookFolderContainsSavedState() {
    let root = URL(fileURLWithPath: "/tmp/cisum-book-state-delete-tests", isDirectory: true)
    let book = root.appendingPathComponent("Book", isDirectory: true)
    let nestedChapter = book
        .appendingPathComponent("Disc 1", isDirectory: true)
        .appendingPathComponent("Chapter 1.m4b")
    let state = BookState(url: book, currentURL: nestedChapter, time: 42)
    let siblingState = BookState(
        url: root.appendingPathComponent("Book Extras", isDirectory: true),
        currentURL: root
            .appendingPathComponent("Book Extras", isDirectory: true)
            .appendingPathComponent("Chapter 1.m4b"),
        time: 42
    )

    #expect(BookDB.contains(book, state: state))
    #expect(!BookDB.contains(book, state: siblingState))
}

@Test func deletedSymlinkedBookFolderContainsRealPathRecords() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realRoot = root.appendingPathComponent("real-books", isDirectory: true)
    let linkedRoot = root.appendingPathComponent("library-link", isDirectory: true)
    let book = realRoot.appendingPathComponent("Book", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: book, withIntermediateDirectories: true)
    try FileManager.default.createSymbolicLink(at: linkedRoot, withDestinationURL: realRoot)
    let nestedChapter = book.appendingPathComponent("Chapter 1.m4b")
    try Data("audio".utf8).write(to: nestedChapter)

    #expect(BookDB.contains(linkedRoot, bookURL: nestedChapter))
}

@Test func deletedRootBookFolderContainsNestedRecords() {
    let root = URL(fileURLWithPath: "/", isDirectory: true)
    let nestedChapter = URL(fileURLWithPath: "/tmp/cisum-root-book/Chapter 1.m4b")

    #expect(BookDB.contains(root, bookURL: nestedChapter))
}

@Test func displayableLibraryItemsIncludeTopLevelStandaloneBooks() {
    let root = URL(fileURLWithPath: "/tmp/cisum-books", isDirectory: true)
    let book = BookDTO(
        url: root.appendingPathComponent("Standalone.m4b"),
        bookTitle: "Standalone",
        childCount: 1,
        isCollection: false,
        order: 0
    )

    #expect(BookRepo.isDisplayableLibraryItem(book, libraryRoot: root))
}

@Test func displayableLibraryItemsIncludeRealBooksUnderSymlinkedLibraryRoot() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realRoot = root.appendingPathComponent("real-books", isDirectory: true)
    let linkedRoot = root.appendingPathComponent("library-link", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: realRoot, withIntermediateDirectories: true)
    try FileManager.default.createSymbolicLink(at: linkedRoot, withDestinationURL: realRoot)
    let bookURL = realRoot.appendingPathComponent("Standalone.m4b")
    try Data("audio".utf8).write(to: bookURL)
    let book = BookDTO(
        url: bookURL,
        bookTitle: "Standalone",
        childCount: 1,
        isCollection: false,
        order: 0
    )

    #expect(BookRepo.isDisplayableLibraryItem(book, libraryRoot: linkedRoot))
}

@Test func displayableLibraryItemsExcludeNestedChapters() {
    let root = URL(fileURLWithPath: "/tmp/cisum-books", isDirectory: true)
    let chapter = BookDTO(
        url: root
            .appendingPathComponent("Novel", isDirectory: true)
            .appendingPathComponent("Chapter 01.m4b"),
        bookTitle: "Chapter 01",
        childCount: 1,
        isCollection: false,
        order: 0
    )

    #expect(!BookRepo.isDisplayableLibraryItem(chapter, libraryRoot: root))
}

@Test func displayableLibraryItemsExcludeEmptyTopLevelFolders() {
    let root = URL(fileURLWithPath: "/tmp/cisum-books", isDirectory: true)
    let emptyFolder = BookDTO(
        url: root.appendingPathComponent("Empty", isDirectory: true),
        bookTitle: "Empty",
        childCount: 0,
        isCollection: true,
        order: 0
    )

    #expect(!BookRepo.isDisplayableLibraryItem(emptyFolder, libraryRoot: root))
}

@Test func bookDBFullSyncInsertsBooksInStablePathOrder() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)

    let schema = Schema([BookModel.self, BookState.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let db = BookDB(container, reason: "bookDBFullSyncInsertsBooksInStablePathOrder")

    let second = root.appendingPathComponent("02-second.m4b")
    let first = root.appendingPathComponent("01-first.m4b")
    for file in [second, first] {
        try Data("audio".utf8).write(to: file)
    }

    await db.sync([second, first], isFirst: true)

    let orderedURLs = try await db.allBookDTOs()
        .sorted { $0.order < $1.order }
        .map(\.url)
    #expect(orderedURLs == [first, second])
}

@Test func bookDBUpdateSyncAppendsNewBooksInStablePathOrder() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)

    let schema = Schema([BookModel.self, BookState.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let db = BookDB(container, reason: "bookDBUpdateSyncAppendsNewBooksInStablePathOrder")

    let existing = root.appendingPathComponent("00-existing.m4b")
    let second = root.appendingPathComponent("02-second.m4b")
    let first = root.appendingPathComponent("01-first.m4b")
    for file in [existing, second, first] {
        try Data("audio".utf8).write(to: file)
    }

    try await db.syncImportedItems([existing])
    try await db.syncImportedItems([second, first])

    let orderedURLs = try await db.allBookDTOs()
        .sorted { $0.order < $1.order }
        .map(\.url)
    #expect(orderedURLs == [existing, first, second])
}

@Test func bookDBUpdateSyncMatchesExistingBookThroughSymlink() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realRoot = root.appendingPathComponent("real-books", isDirectory: true)
    let linkedRoot = root.appendingPathComponent("library-link", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: realRoot, withIntermediateDirectories: true)
    try FileManager.default.createSymbolicLink(at: linkedRoot, withDestinationURL: realRoot)

    let schema = Schema([BookModel.self, BookState.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let db = BookDB(container, reason: "bookDBUpdateSyncMatchesExistingBookThroughSymlink")

    let realBook = realRoot.appendingPathComponent("Novel.m4b")
    let linkedBook = linkedRoot.appendingPathComponent("Novel.m4b")
    try Data("audio".utf8).write(to: realBook)

    try await db.insertModel(BookModel(url: realBook, order: 10))
    try await db.syncImportedItems([linkedBook])

    let books = try await db.allBookDTOs()
    #expect(books.count == 1)
    #expect(books.first?.url == realBook)
    #expect(books.first?.order == 10)
}

@Test func bookDBFullSyncKeepsSymlinkedExistingBookState() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realRoot = root.appendingPathComponent("real-books", isDirectory: true)
    let linkedRoot = root.appendingPathComponent("library-link", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: realRoot, withIntermediateDirectories: true)
    try FileManager.default.createSymbolicLink(at: linkedRoot, withDestinationURL: realRoot)

    let schema = Schema([BookModel.self, BookState.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let db = BookDB(container, reason: "bookDBFullSyncKeepsSymlinkedExistingBookState")

    let realBook = realRoot.appendingPathComponent("Novel.m4b")
    let linkedBook = linkedRoot.appendingPathComponent("Novel.m4b")
    try Data("audio".utf8).write(to: realBook)

    try await db.insertModel(BookModel(url: realBook, order: 10))
    await db.updateBookCurrent(realBook, currentURL: realBook, time: 42)
    await db.sync([linkedBook], isFirst: true)

    let books = try await db.allBookDTOs()
    #expect(books.count == 1)
    #expect(books.first?.url == realBook)
    #expect(books.first?.order == 10)
    #expect(await db.getBookTime(realBook) == 42)
}

@Test func bookDBFullSyncDeduplicatesSymlinkedScanItems() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realRoot = root.appendingPathComponent("real-books", isDirectory: true)
    let linkedRoot = root.appendingPathComponent("library-link", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: realRoot, withIntermediateDirectories: true)
    try FileManager.default.createSymbolicLink(at: linkedRoot, withDestinationURL: realRoot)

    let schema = Schema([BookModel.self, BookState.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let db = BookDB(container, reason: "bookDBFullSyncDeduplicatesSymlinkedScanItems")

    let realBook = realRoot.appendingPathComponent("Novel.m4b")
    let linkedBook = linkedRoot.appendingPathComponent("Novel.m4b")
    try Data("audio".utf8).write(to: realBook)

    await db.sync([linkedBook, realBook], isFirst: true)

    let books = try await db.allBookDTOs()
    #expect(books.map(\.url) == [linkedBook])
}

@Test func bookDBFindsBookStateThroughSymlink() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realRoot = root.appendingPathComponent("real-books", isDirectory: true)
    let linkedRoot = root.appendingPathComponent("library-link", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: realRoot, withIntermediateDirectories: true)
    try FileManager.default.createSymbolicLink(at: linkedRoot, withDestinationURL: realRoot)

    let schema = Schema([BookModel.self, BookState.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let db = BookDB(container, reason: "bookDBFindsBookStateThroughSymlink")

    let realBook = realRoot.appendingPathComponent("Novel", isDirectory: true)
    let linkedBook = linkedRoot.appendingPathComponent("Novel", isDirectory: true)
    try FileManager.default.createDirectory(at: realBook, withIntermediateDirectories: true)
    try Data("audio".utf8).write(to: realBook.appendingPathComponent("Chapter 01.m4b"))

    await db.updateBookCurrent(realBook, currentURL: realBook.appendingPathComponent("Chapter 01.m4b"), time: 42)

    #expect(await db.getBookTime(linkedBook) == 42)
}

@Test func bookDBSyncKeepsSymlinkedBookFolderDisplayable() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realRoot = root.appendingPathComponent("real-books", isDirectory: true)
    let linkedRoot = root.appendingPathComponent("library-link", isDirectory: true)
    let realBook = realRoot.appendingPathComponent("Novel", isDirectory: true)
    let linkedBook = linkedRoot.appendingPathComponent("Novel", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: realBook, withIntermediateDirectories: true)
    try FileManager.default.createSymbolicLink(at: linkedRoot, withDestinationURL: realRoot)
    try Data("audio".utf8).write(to: realBook.appendingPathComponent("Chapter 01.m4b"))

    let schema = Schema([BookModel.self, BookState.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let db = BookDB(container, reason: "bookDBSyncKeepsSymlinkedBookFolderDisplayable")

    await db.sync([linkedBook], isFirst: true)

    let book = try #require(await db.allBookDTOs().first)
    #expect(book.isCollection)
    #expect(book.childCount == 1)
    #expect(BookRepo.isDisplayableLibraryItem(book, libraryRoot: linkedRoot))
}

@Test func bookDBFullSyncIgnoresUnsupportedFiles() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)

    let schema = Schema([BookModel.self, BookState.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let db = BookDB(container, reason: "bookDBFullSyncIgnoresUnsupportedFiles")

    let book = root.appendingPathComponent("Novel.m4b")
    let notes = root.appendingPathComponent("notes.txt")
    try Data("audio".utf8).write(to: book)
    try Data("notes".utf8).write(to: notes)

    await db.sync([notes, book], isFirst: true)

    let books = try await db.allBookDTOs()
    #expect(books.map(\.url) == [book])
}

@Test func bookDBUpdateSyncIgnoresUnsupportedFilesAndFolders() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)

    let schema = Schema([BookModel.self, BookState.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let db = BookDB(container, reason: "bookDBUpdateSyncIgnoresUnsupportedFilesAndFolders")

    let book = root.appendingPathComponent("Novel.m4b")
    let notes = root.appendingPathComponent("notes.txt")
    let emptyFolder = root.appendingPathComponent("Empty", isDirectory: true)
    try Data("audio".utf8).write(to: book)
    try Data("notes".utf8).write(to: notes)
    try FileManager.default.createDirectory(at: emptyFolder, withIntermediateDirectories: true)

    try await db.syncImportedItems([notes, emptyFolder, book])

    let books = try await db.allBookDTOs()
    #expect(books.map(\.url) == [book])
}

@Test func bookDBNextBookUsesCurrentBookOrder() async throws {
    let schema = Schema([BookModel.self, BookState.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let db = BookDB(container, reason: "bookDBNextBookUsesCurrentBookOrder")

    let root = URL(fileURLWithPath: "/tmp/cisum-book-next-tests", isDirectory: true)
    let first = root.appendingPathComponent("first.m4b")
    let second = root.appendingPathComponent("second.m4b")
    let third = root.appendingPathComponent("third.m4b")

    try await db.insertModel(BookModel(url: first, order: 10))
    try await db.insertModel(BookModel(url: second, order: 20))
    try await db.insertModel(BookModel(url: third, order: 30))

    #expect(db.getNextBookOf(second)?.url == third)
}

@Test func bookDBFindOrCreateReturnsInsertedBook() async throws {
    let schema = Schema([BookModel.self, BookState.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let db = BookDB(container, reason: "bookDBFindOrCreateReturnsInsertedBook")

    let bookURL = URL(fileURLWithPath: "/tmp/cisum-book-find-or-create/Novel.m4b")
    #expect(await db.findOrCreateReturnsInsertedBook(bookURL))
}

@Test func bookDBFullSyncRepairsDuplicateLegacyBookOrders() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)

    let schema = Schema([BookModel.self, BookState.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let db = BookDB(container, reason: "bookDBFullSyncRepairsDuplicateLegacyBookOrders")

    let second = root.appendingPathComponent("02-second.m4b")
    let first = root.appendingPathComponent("01-first.m4b")
    for file in [second, first] {
        try Data("audio".utf8).write(to: file)
        try await db.insertModel(BookModel(url: file, order: 0))
    }

    await db.sync([second, first], isFirst: true)

    let books = try await db.allBookDTOs()
        .sorted { $0.order < $1.order }
    #expect(books.map(\.url) == [first, second])
    #expect(Set(books.map(\.order)).count == 2)
}

@Test func bookDBKeepsUniqueExistingBookOrders() {
    #expect(!BookDB.needsStableOrderRepair([20, 10, 30]))
    #expect(BookDB.needsStableOrderRepair([0, 0]))
}

extension BookDB {
    func findOrCreateReturnsInsertedBook(_ url: URL) -> Bool {
        guard let created = findOrCreateBook(url), let fetched = findBook(url: url) else {
            return false
        }

        return created === fetched
    }
}
