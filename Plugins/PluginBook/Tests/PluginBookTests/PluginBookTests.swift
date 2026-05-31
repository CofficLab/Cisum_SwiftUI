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
