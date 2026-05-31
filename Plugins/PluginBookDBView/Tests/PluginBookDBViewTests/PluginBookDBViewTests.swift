import Testing
@testable import PluginBookDBView
import Foundation
import PluginBook
import SwiftData
import UniformTypeIdentifiers

@Test func bookDBInfoExportsMetadata() {
    #expect(BookDBPluginInfo.table == "Book-DBView")
    #expect(BookDBPluginInfo.iconName == "books.vertical")
}

@Test func folderImportRequiresPlayableFiles() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    let unsupportedFolder = root.appendingPathComponent("unsupported", isDirectory: true)
    let supportedFolder = root.appendingPathComponent("supported", isDirectory: true)
    let nestedFolder = supportedFolder.appendingPathComponent("disc-1", isDirectory: true)

    try FileManager.default.createDirectory(at: unsupportedFolder, withIntermediateDirectories: true)
    try Data("notes".utf8).write(to: unsupportedFolder.appendingPathComponent("notes.txt"))

    try FileManager.default.createDirectory(at: nestedFolder, withIntermediateDirectories: true)
    try Data("audio".utf8).write(to: nestedFolder.appendingPathComponent("chapter.m4b"))

    #expect(BookDBView.folderContainsPlayableFiles(unsupportedFolder) == false)
    #expect(BookDBView.folderContainsPlayableFiles(supportedFolder) == true)
}

@Test func folderImportAcceptsSymlinkedBookFolders() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realBook = root.appendingPathComponent("RealBook", isDirectory: true)
    let linkedBook = root.appendingPathComponent("LinkedBook", isDirectory: true)
    let destinationRoot = root.appendingPathComponent("destination", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: realBook, withIntermediateDirectories: true)
    try FileManager.default.createSymbolicLink(at: linkedBook, withDestinationURL: realBook)
    try Data("audio".utf8).write(to: realBook.appendingPathComponent("001.m4b"))

    #expect(BookDBView.isFolderLikeImportSource(linkedBook))
    #expect(BookDBView.folderContainsPlayableFiles(linkedBook))

    let copiedItems = try await BookDBView.copyImportedItems([linkedBook], to: destinationRoot)
    let copiedBook = destinationRoot.appendingPathComponent("LinkedBook", isDirectory: true)

    #expect(copiedItems == [copiedBook])
    #expect(FileManager.default.fileExists(atPath: copiedBook.appendingPathComponent("001.m4b").path))
}

@Test func bookImportCleansCopiedItemsWhenBatchFails() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let sourceRoot = root.appendingPathComponent("source", isDirectory: true)
    let destinationRoot = root.appendingPathComponent("destination", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: sourceRoot, withIntermediateDirectories: true)
    let validSource = sourceRoot.appendingPathComponent("chapter-1.m4b")
    let missingSource = sourceRoot.appendingPathComponent("chapter-2.m4b")
    try Data("audio".utf8).write(to: validSource)

    await #expect(throws: Error.self) {
        try await BookDBView.copyImportedItems([validSource, missingSource], to: destinationRoot)
    }

    #expect(FileManager.default.fileExists(atPath: destinationRoot.appendingPathComponent("source").path) == false)
}

@Test func bookImportRejectsDestinationInsideSourceFolderBeforeCopying() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let sourceRoot = root.appendingPathComponent("source", isDirectory: true)
    let destinationRoot = sourceRoot.appendingPathComponent("library", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: sourceRoot, withIntermediateDirectories: true)
    let chapter = sourceRoot.appendingPathComponent("chapter-1.m4b")
    try Data("audio".utf8).write(to: chapter)

    #expect(BookDBView.isDestinationNestedInSource(
        source: sourceRoot,
        destination: destinationRoot.appendingPathComponent("source", isDirectory: true)
    ))

    await #expect(throws: Error.self) {
        try await BookDBView.copyImportedItems([sourceRoot], to: destinationRoot)
    }

    #expect(FileManager.default.fileExists(atPath: chapter.path))
    #expect(!FileManager.default.fileExists(atPath: destinationRoot.appendingPathComponent("source").path))
}

@Test func bookImportTreatsRootSourceAsContainingDestination() {
    let source = URL(fileURLWithPath: "/", isDirectory: true)
    let destination = URL(fileURLWithPath: "/tmp/cisum-book-import/source", isDirectory: true)

    #expect(BookDBView.isDestinationNestedInSource(source: source, destination: destination))
    #expect(!BookDBView.isDestinationNestedInSource(source: source, destination: source))
}

@Test func bookImportRejectsSymlinkedDestinationInsideSourceFolder() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let sourceRoot = root.appendingPathComponent("source", isDirectory: true)
    let realLibrary = sourceRoot.appendingPathComponent("library", isDirectory: true)
    let linkedLibrary = root.appendingPathComponent("linked-library", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: realLibrary, withIntermediateDirectories: true)
    try FileManager.default.createSymbolicLink(at: linkedLibrary, withDestinationURL: realLibrary)
    let chapter = sourceRoot.appendingPathComponent("chapter-1.m4b")
    try Data("audio".utf8).write(to: chapter)

    let destination = linkedLibrary.appendingPathComponent("source", isDirectory: true)
    #expect(BookDBView.isDestinationNestedInSource(source: sourceRoot, destination: destination))

    await #expect(throws: Error.self) {
        try await BookDBView.copyImportedItems([sourceRoot], to: linkedLibrary)
    }

    #expect(FileManager.default.fileExists(atPath: chapter.path))
    #expect(!FileManager.default.fileExists(atPath: destination.path))
}

@Test func bookDropReadsFileURLDataProvider() async throws {
    let expected = URL(fileURLWithPath: "/tmp/cisum-book-drop-provider-tests/audiobook")
    let provider = NSItemProvider()
    provider.registerDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier, visibility: .all) { completion in
        completion(expected.dataRepresentation, nil)
        return nil
    }

    let url = try await BookDBView.droppedFileURL(from: provider)

    #expect(url == expected)
}

@Test func bookDropSkipsEmptyImportAfterProviderFailure() {
    let error = NSError(domain: "BookDrop", code: 1)
    let url = URL(fileURLWithPath: "/tmp/cisum-book-drop-provider-tests/audiobook")

    #expect(BookDBView.shouldImportDroppedURLs([], after: [error]) == false)
    #expect(BookDBView.shouldImportDroppedURLs([url], after: [error]) == true)
    #expect(BookDBView.shouldImportDroppedURLs([], after: []) == true)
}

@Test func bookImportDoesNotStartWhileAlreadyImporting() {
    #expect(BookDBView.shouldStartImport(isImporting: false))
    #expect(!BookDBView.shouldStartImport(isImporting: true))
}

@Test func bookImportAllowsReadableLocalItemsWithoutSecurityScope() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    let readableFolder = root.appendingPathComponent("book", isDirectory: true)
    let missingFolder = root.appendingPathComponent("missing", isDirectory: true)
    try FileManager.default.createDirectory(at: readableFolder, withIntermediateDirectories: true)

    #expect(BookDBView.hasImportSourceAccess(readableFolder, securityScopeGranted: false))
    #expect(BookDBView.hasImportSourceAccess(missingFolder, securityScopeGranted: true))
    #expect(!BookDBView.hasImportSourceAccess(missingFolder, securityScopeGranted: false))
}

@Test func bookPlaybackOrderingUsesRelativePaths() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    let disc1 = root.appendingPathComponent("Disc 1", isDirectory: true)
    let disc2 = root.appendingPathComponent("Disc 2", isDirectory: true)
    try FileManager.default.createDirectory(at: disc1, withIntermediateDirectories: true)
    try FileManager.default.createDirectory(at: disc2, withIntermediateDirectories: true)

    let disc1Chapter2 = disc1.appendingPathComponent("02.m4b")
    let disc2Chapter1 = disc2.appendingPathComponent("01.m4b")
    try Data("audio".utf8).write(to: disc1Chapter2)
    try Data("audio".utf8).write(to: disc2Chapter1)

    let playable = BookPlaybackOrdering.playableChildren(for: root)

    #expect(playable.map { BookPlaybackOrdering.relativePath($0, in: root) } == [
        "Disc 1/02.m4b",
        "Disc 2/01.m4b",
    ])
    #expect(BookPlaybackOrdering.relativePath(disc1Chapter2, in: root) == "Disc 1/02.m4b")
}

@Test func bookPlaybackOrderingRejectsSiblingPrefixPaths() {
    let root = URL(fileURLWithPath: "/tmp/cisum-books/Book", isDirectory: true)
    let sibling = URL(fileURLWithPath: "/tmp/cisum-books/Book Backup/01.m4b")

    #expect(BookPlaybackOrdering.relativePath(sibling, in: root) == "01.m4b")
}

@Test func bookPlaybackOrderingMatchesSymlinkedPlayableChildren() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realBook = root.appendingPathComponent("RealBook", isDirectory: true)
    let linkedBook = root.appendingPathComponent("LinkedBook", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: realBook, withIntermediateDirectories: true)
    try FileManager.default.createSymbolicLink(at: linkedBook, withDestinationURL: realBook)
    let savedChapter = realBook.appendingPathComponent("001.m4b")
    try Data("audio".utf8).write(to: savedChapter)

    let playable = BookPlaybackOrdering.playableChildren(for: linkedBook)

    #expect(BookPlaybackOrdering.contains(savedChapter, in: playable))
    #expect(BookPlaybackOrdering.representsSameFile(
        savedChapter,
        linkedBook.appendingPathComponent("001.m4b")
    ))
}

@Test func bookTileReloadsWhenDatabaseRootChanges() {
    let bookURL = URL(fileURLWithPath: "/tmp/cisum-book-tile/book")
    let firstRoot = URL(fileURLWithPath: "/tmp/cisum-book-tile/db-1")
    let secondRoot = URL(fileURLWithPath: "/tmp/cisum-book-tile/db-2")

    #expect(BookTileLoadIdentity(bookURL: bookURL, dbRoot: firstRoot) == BookTileLoadIdentity(bookURL: bookURL, dbRoot: firstRoot))
    #expect(BookTileLoadIdentity(bookURL: bookURL, dbRoot: firstRoot) != BookTileLoadIdentity(bookURL: bookURL, dbRoot: secondRoot))
}

@Test func bookDBViewFindsSymlinkedBookState() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realRoot = root.appendingPathComponent("real-books", isDirectory: true)
    let linkedRoot = root.appendingPathComponent("library-link", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: realRoot, withIntermediateDirectories: true)
    try FileManager.default.createSymbolicLink(at: linkedRoot, withDestinationURL: realRoot)
    let realBook = realRoot.appendingPathComponent("Novel", isDirectory: true)
    let linkedBook = linkedRoot.appendingPathComponent("Novel", isDirectory: true)
    try FileManager.default.createDirectory(at: realBook, withIntermediateDirectories: true)
    let realChapter = realBook.appendingPathComponent("Chapter 01.m4b")
    try Data("audio".utf8).write(to: realChapter)

    let schema = Schema([BookModel.self, BookState.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let context = ModelContext(container)
    context.insert(BookState(url: realBook, currentURL: realChapter, time: 42))
    try context.save()

    let state = try #require(try BookDBViewBookStateLookup.findBookState(for: linkedBook, in: context))
    #expect(state.currentURL == realChapter)
    #expect(state.time == 42)
}

@Test func bookGridOnlyAppliesCurrentUpdateGeneration() {
    #expect(BookGridUpdatePolicy.shouldApplyResult(currentGeneration: 2, resultGeneration: 2))
    #expect(!BookGridUpdatePolicy.shouldApplyResult(currentGeneration: 3, resultGeneration: 2))
}
