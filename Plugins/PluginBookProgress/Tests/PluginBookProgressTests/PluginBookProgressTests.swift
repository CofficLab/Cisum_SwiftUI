import Foundation
@testable import PluginBookProgress
import Testing

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(BookProgressPluginInfo.iconName == "book.closed")
    #expect(BookProgressPluginInfo.order == 5)
}

@Test func currentURLChangesDoNotOverwriteSavedPlaybackTime() {
    let url = URL(fileURLWithPath: "/tmp/book/chapter-01.mp3")

    let snapshot = BookProgressPersistencePolicy.currentURLChangeSnapshot(currentURL: url)

    #expect(snapshot == BookProgressStateSnapshot(currentURL: url, time: nil))
}

@Test func clearingCurrentURLClearsGlobalBookWithoutSavingChapterState() {
    let snapshot = BookProgressPersistencePolicy.currentURLChangeSnapshot(currentURL: nil)

    #expect(snapshot == nil)
}

@Test func differentCurrentBookURLResetsGlobalRestoreTime() {
    let oldURL = URL(fileURLWithPath: "/tmp/book/chapter-01.mp3")
    let newURL = URL(fileURLWithPath: "/tmp/book/chapter-02.mp3")

    #expect(BookProgressPersistencePolicy.shouldResetGlobalTimeWhenCurrentURLChanges(from: oldURL, to: newURL))
    #expect(BookProgressPersistencePolicy.shouldResetGlobalTimeWhenCurrentURLChanges(from: oldURL, to: nil))
    #expect(!BookProgressPersistencePolicy.shouldResetGlobalTimeWhenCurrentURLChanges(from: oldURL, to: oldURL))
}

@Test func invalidRestoredBookURLShouldClearCurrentBook() {
    let url = URL(fileURLWithPath: "/tmp/book/missing.mp3")

    #expect(BookProgressPersistencePolicy.shouldClearRestoredCurrentURL(currentURL: url, isPlayable: false))
    #expect(!BookProgressPersistencePolicy.shouldClearRestoredCurrentURL(currentURL: url, isPlayable: true))
    #expect(!BookProgressPersistencePolicy.shouldClearRestoredCurrentURL(currentURL: nil, isPlayable: false))
}

@Test func playbackPositionChangesPersistCurrentTime() {
    let url = URL(fileURLWithPath: "/tmp/book/chapter-01.mp3")

    let snapshot = BookProgressPersistencePolicy.snapshot(
        currentURL: url,
        currentTime: 42,
        trigger: .playbackPositionChanged
    )

    #expect(snapshot == BookProgressStateSnapshot(currentURL: url, time: 42))
}

@Test func rootLevelBookFileResolvesToItself() {
    let disk = URL(fileURLWithPath: "/tmp/cisum-books", isDirectory: true)
    let book = disk.appendingPathComponent("Standalone.m4b")

    let root = BookProgressBookRootResolver.bookRoot(containing: book, bookDisk: disk)

    #expect(root == book.standardizedFileURL)
}

@Test func nestedBookChapterResolvesToTopLevelBookFolder() {
    let disk = URL(fileURLWithPath: "/tmp/cisum-books", isDirectory: true)
    let book = disk.appendingPathComponent("Novel", isDirectory: true)
    let chapter = book
        .appendingPathComponent("Disc 1", isDirectory: true)
        .appendingPathComponent("Chapter 01.mp3")

    let root = BookProgressBookRootResolver.bookRoot(containing: chapter, bookDisk: disk)

    #expect(root == book.standardizedFileURL)
}

@Test func outsideBookDiskFallsBackToParentFolder() {
    let disk = URL(fileURLWithPath: "/tmp/cisum-books", isDirectory: true)
    let chapter = URL(fileURLWithPath: "/tmp/other-books/Novel/Chapter 01.mp3")

    let root = BookProgressBookRootResolver.bookRoot(containing: chapter, bookDisk: disk)

    #expect(root == chapter.deletingLastPathComponent().standardizedFileURL)
}
