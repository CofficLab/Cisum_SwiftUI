@testable import PluginBook
import Foundation
import Testing

@Test func bookPluginInfoExportsMetadata() {
    #expect(BookPluginInfo.dirName == "audios_book")
    #expect(BookPluginInfo.iconName == "book")
    #expect(BookPluginInfo.supportedExtensions.contains("m4b"))
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
