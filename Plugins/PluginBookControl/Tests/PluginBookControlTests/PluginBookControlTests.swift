import Testing
import SwiftUI
@testable import PluginBookControl

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(BookControlPluginInfo.iconName == "playpause")
    #expect(BookControlPluginInfo.order == 8)
}

@Test func repeatAllWrapsBookChapterNavigation() {
    let chapters = [
        URL(fileURLWithPath: "/tmp/book/001.m4b"),
        URL(fileURLWithPath: "/tmp/book/002.m4b"),
        URL(fileURLWithPath: "/tmp/book/003.m4b"),
    ]

    let next = BookControlRootView<EmptyView>.adjacentAsset(
        in: chapters,
        current: chapters[2],
        offset: 1,
        playMode: .repeatAll
    )
    let previous = BookControlRootView<EmptyView>.adjacentAsset(
        in: chapters,
        current: chapters[0],
        offset: -1,
        playMode: .repeatAll
    )
    let sequenceNext = BookControlRootView<EmptyView>.adjacentAsset(
        in: chapters,
        current: chapters[2],
        offset: 1,
        playMode: .sequence
    )

    #expect(next == chapters[0])
    #expect(previous == chapters[2])
    #expect(sequenceNext == nil)
}

@Test func chapterNavigationMatchesSymlinkedCurrentChapter() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realBook = root.appendingPathComponent("RealBook", isDirectory: true)
    let linkedBook = root.appendingPathComponent("LinkedBook", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: realBook, withIntermediateDirectories: true)
    try FileManager.default.createSymbolicLink(at: linkedBook, withDestinationURL: realBook)
    let currentChapter = realBook.appendingPathComponent("001.m4b")
    let nextChapter = realBook.appendingPathComponent("002.m4b")
    try Data("audio".utf8).write(to: currentChapter)
    try Data("audio".utf8).write(to: nextChapter)

    let chapters = BookControlChapterLoader.playableChapters(in: linkedBook)
    let next = BookControlRootView<EmptyView>.adjacentAsset(
        in: chapters,
        current: currentChapter,
        offset: 1,
        playMode: .sequence
    )

    #expect(next == linkedBook.appendingPathComponent("002.m4b"))
}

@Test func shuffledChapterCandidatesExcludeSymlinkedCurrentChapter() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realBook = root.appendingPathComponent("RealBook", isDirectory: true)
    let linkedBook = root.appendingPathComponent("LinkedBook", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: realBook, withIntermediateDirectories: true)
    try FileManager.default.createSymbolicLink(at: linkedBook, withDestinationURL: realBook)
    let realCurrentChapter = realBook.appendingPathComponent("001.m4b")
    let linkedCurrentChapter = linkedBook.appendingPathComponent("001.m4b")
    let linkedNextChapter = linkedBook.appendingPathComponent("002.m4b")
    try Data("audio".utf8).write(to: realCurrentChapter)
    try Data("audio".utf8).write(to: realBook.appendingPathComponent("002.m4b"))

    let candidates = BookControlChapterLoader.shuffleCandidates(
        in: [linkedCurrentChapter, linkedNextChapter],
        current: realCurrentChapter
    )

    #expect(candidates == [linkedNextChapter])
}

@Test func navigationResultOnlyAppliesToUnchangedCurrentChapter() {
    let requested = URL(fileURLWithPath: "/tmp/book/001.m4b")
    let switched = URL(fileURLWithPath: "/tmp/book/002.m4b")

    #expect(BookControlPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: requested,
        currentAsset: requested,
        isSceneActive: true
    ))
    #expect(!BookControlPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: requested,
        currentAsset: switched,
        isSceneActive: true
    ))
    #expect(!BookControlPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: requested,
        currentAsset: nil,
        isSceneActive: true
    ))
    #expect(!BookControlPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: requested,
        currentAsset: requested,
        isSceneActive: false
    ))
}

@Test func navigationResultAppliesToSymlinkedCurrentChapter() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realBook = root.appendingPathComponent("RealBook", isDirectory: true)
    let linkedBook = root.appendingPathComponent("LinkedBook", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: realBook, withIntermediateDirectories: true)
    try FileManager.default.createSymbolicLink(at: linkedBook, withDestinationURL: realBook)
    let realChapter = realBook.appendingPathComponent("001.m4b")
    let linkedChapter = linkedBook.appendingPathComponent("001.m4b")
    try Data("audio".utf8).write(to: realChapter)

    #expect(BookControlPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: linkedChapter,
        currentAsset: realChapter,
        isSceneActive: true
    ))
}

@Test func staleNavigationDoesNotApplyAfterSceneReactivation() {
    let requested = URL(fileURLWithPath: "/tmp/book/001.m4b")
    let generation = BookControlPlaybackRequestPolicy.generationAfterDeactivation(2)

    #expect(BookControlPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: requested,
        currentAsset: requested,
        isSceneActive: true,
        currentGeneration: 2,
        requestGeneration: 2
    ))
    #expect(!BookControlPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: requested,
        currentAsset: requested,
        isSceneActive: true,
        currentGeneration: generation,
        requestGeneration: 2
    ))
}

@Test func navigationRejectsCurrentAudioOutsideConfiguredBookDisk() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let bookDisk = root.appendingPathComponent("books", isDirectory: true)
    let outside = root.appendingPathComponent("outside", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: bookDisk, withIntermediateDirectories: true)
    try FileManager.default.createDirectory(at: outside, withIntermediateDirectories: true)

    let chapter = bookDisk
        .appendingPathComponent("Novel", isDirectory: true)
        .appendingPathComponent("Chapter 01.m4b")
    try FileManager.default.createDirectory(
        at: chapter.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )
    try Data("book".utf8).write(to: chapter)

    let outsideAudio = outside.appendingPathComponent("Track.m4b")
    try Data("audio".utf8).write(to: outsideAudio)

    #expect(BookControlPlaybackRequestPolicy.shouldNavigateBookAsset(chapter, bookDisk: bookDisk))
    #expect(!BookControlPlaybackRequestPolicy.shouldNavigateBookAsset(outsideAudio, bookDisk: bookDisk))
    #expect(BookControlPlaybackRequestPolicy.shouldNavigateBookAsset(outsideAudio, bookDisk: nil))
}

@Test func deletionAffectsCurrentChapterInsideDeletedBook() {
    let deletedBook = URL(fileURLWithPath: "/tmp/books/Novel", isDirectory: true)
    let currentChapter = deletedBook.appendingPathComponent("Chapter 01.m4b")
    let otherChapter = URL(fileURLWithPath: "/tmp/books/Other/Chapter 01.m4b")

    #expect(BookControlPlaybackRequestPolicy.currentAssetAffectedByDeletion(
        currentAsset: currentChapter,
        deletedURLs: [deletedBook]
    ))
    #expect(!BookControlPlaybackRequestPolicy.currentAssetAffectedByDeletion(
        currentAsset: otherChapter,
        deletedURLs: [deletedBook]
    ))
    #expect(!BookControlPlaybackRequestPolicy.currentAssetAffectedByDeletion(
        currentAsset: nil,
        deletedURLs: [deletedBook]
    ))
}

@Test func deletionAffectsCurrentChapterThroughSymlinkedBook() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realBook = root.appendingPathComponent("RealBook", isDirectory: true)
    let linkedBook = root.appendingPathComponent("LinkedBook", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: realBook, withIntermediateDirectories: true)
    try FileManager.default.createSymbolicLink(at: linkedBook, withDestinationURL: realBook)
    let currentChapter = realBook.appendingPathComponent("Chapter 01.m4b")
    try Data("audio".utf8).write(to: currentChapter)

    #expect(BookControlPlaybackRequestPolicy.currentAssetAffectedByDeletion(
        currentAsset: currentChapter,
        deletedURLs: [linkedBook]
    ))
}

@Test func deletionAffectsCurrentChapterUnderDanglingSymlinkedBook() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let missingBook = root.appendingPathComponent("MissingBook", isDirectory: true)
    let linkedBook = root.appendingPathComponent("LinkedBook", isDirectory: true)
    let currentChapter = linkedBook.appendingPathComponent("Chapter 01.m4b")
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    try FileManager.default.createSymbolicLink(at: linkedBook, withDestinationURL: missingBook)

    #expect(BookControlPlaybackRequestPolicy.currentAssetAffectedByDeletion(
        currentAsset: currentChapter,
        deletedURLs: [linkedBook]
    ))
}

@Test func staleDeletionResetDoesNotApplyAfterSceneReactivation() {
    let deletedBook = URL(fileURLWithPath: "/tmp/books/Novel", isDirectory: true)
    let currentChapter = deletedBook.appendingPathComponent("Chapter 01.m4b")
    let generation = BookControlPlaybackRequestPolicy.generationAfterDeactivation(2)

    #expect(BookControlPlaybackRequestPolicy.shouldApplyDeletionReset(
        currentAsset: currentChapter,
        deletedURLs: [deletedBook],
        currentGeneration: 2,
        requestGeneration: 2
    ))
    #expect(!BookControlPlaybackRequestPolicy.shouldApplyDeletionReset(
        currentAsset: currentChapter,
        deletedURLs: [deletedBook],
        currentGeneration: generation,
        requestGeneration: 2
    ))
}

@Test func storageResetOnlyAppliesInActiveBookScene() {
    #expect(BookControlPlaybackRequestPolicy.shouldResetForStorageLocationChange(isSceneActive: true))
    #expect(!BookControlPlaybackRequestPolicy.shouldResetForStorageLocationChange(isSceneActive: false))
}

@Test func staleBookStorageResetDoesNotApplyAfterDeactivation() {
    let generation = BookControlPlaybackRequestPolicy.generationAfterDeactivation(2)

    #expect(generation == 3)
    #expect(BookControlPlaybackRequestPolicy.shouldApplyStorageReset(
        currentGeneration: 2,
        requestGeneration: 2,
        isSceneActive: true
    ))
    #expect(!BookControlPlaybackRequestPolicy.shouldApplyStorageReset(
        currentGeneration: generation,
        requestGeneration: 2,
        isSceneActive: true
    ))
    #expect(!BookControlPlaybackRequestPolicy.shouldApplyStorageReset(
        currentGeneration: 2,
        requestGeneration: 2,
        isSceneActive: false
    ))
}

@Test func bookRootUsesStandaloneBookAtDiskRoot() {
    let disk = URL(fileURLWithPath: "/tmp/cisum-books", isDirectory: true)
    let book = disk.appendingPathComponent("Standalone.m4b")

    let root = BookControlBookRootResolver.bookRoot(containing: book, bookDisk: disk)

    #expect(root == book.standardizedFileURL)
}

@Test func bookRootUsesTopLevelFolderForChapterBooks() {
    let disk = URL(fileURLWithPath: "/tmp/cisum-books", isDirectory: true)
    let book = disk.appendingPathComponent("Novel", isDirectory: true)
    let chapter = book
        .appendingPathComponent("Part 1", isDirectory: true)
        .appendingPathComponent("Chapter 01.m4b")

    let root = BookControlBookRootResolver.bookRoot(containing: chapter, bookDisk: disk)

    #expect(root == book.standardizedFileURL)
}

@Test func bookRootFallsBackToParentOutsideBookDisk() {
    let disk = URL(fileURLWithPath: "/tmp/cisum-books", isDirectory: true)
    let chapter = URL(fileURLWithPath: "/tmp/other-books/Novel/Chapter 01.m4b")

    let root = BookControlBookRootResolver.bookRoot(containing: chapter, bookDisk: disk)

    #expect(root == chapter.deletingLastPathComponent().standardizedFileURL)
}

@Test func bookRootMapsSymlinkedBookDiskToConfiguredRoot() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realDisk = root.appendingPathComponent("real-books", isDirectory: true)
    let linkedDisk = root.appendingPathComponent("library-link", isDirectory: true)
    let book = realDisk.appendingPathComponent("Novel", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: book, withIntermediateDirectories: true)
    try FileManager.default.createSymbolicLink(at: linkedDisk, withDestinationURL: realDisk)
    let chapter = book.appendingPathComponent("Chapter 01.m4b")
    try Data("audio".utf8).write(to: chapter)

    let resolved = BookControlBookRootResolver.bookRoot(containing: chapter, bookDisk: linkedDisk)

    #expect(resolved == linkedDisk.appendingPathComponent("Novel", isDirectory: true).standardizedFileURL)
}

@Test func chapterLoaderReturnsPlayableChaptersInRelativeOrder() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    let disc1 = root.appendingPathComponent("Disc 1", isDirectory: true)
    let disc2 = root.appendingPathComponent("Disc 2", isDirectory: true)
    try FileManager.default.createDirectory(at: disc1, withIntermediateDirectories: true)
    try FileManager.default.createDirectory(at: disc2, withIntermediateDirectories: true)

    let unsupported = disc1.appendingPathComponent("notes.txt")
    let chapter2 = disc1.appendingPathComponent("02.m4b")
    let chapter1 = disc2.appendingPathComponent("01.m4b")
    try Data("notes".utf8).write(to: unsupported)
    try Data("audio".utf8).write(to: chapter2)
    try Data("audio".utf8).write(to: chapter1)

    let chapters = BookControlChapterLoader.playableChapters(in: root)

    #expect(chapters.map { BookControlChapterLoader.relativePath($0, in: root) } == [
        "Disc 1/02.m4b",
        "Disc 2/01.m4b",
    ])
}

@Test func chapterLoaderRejectsSiblingPrefixPaths() {
    let root = URL(fileURLWithPath: "/tmp/cisum-books/Book", isDirectory: true)
    let sibling = URL(fileURLWithPath: "/tmp/cisum-books/Book Backup/01.m4b")

    #expect(BookControlChapterLoader.relativePath(sibling, in: root) == "01.m4b")
}
