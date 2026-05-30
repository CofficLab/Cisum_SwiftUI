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

@Test func navigationResultOnlyAppliesToUnchangedCurrentChapter() {
    let requested = URL(fileURLWithPath: "/tmp/book/001.m4b")
    let switched = URL(fileURLWithPath: "/tmp/book/002.m4b")

    #expect(BookControlPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: requested,
        currentAsset: requested
    ))
    #expect(!BookControlPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: requested,
        currentAsset: switched
    ))
    #expect(!BookControlPlaybackRequestPolicy.shouldApplyNavigationResult(
        requestedAsset: requested,
        currentAsset: nil
    ))
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
