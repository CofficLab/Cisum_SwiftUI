@testable import PluginBook
import Foundation
import Testing

@Test func bookPluginInfoExportsMetadata() {
    #expect(BookPluginInfo.dirName == "audios_book")
    #expect(BookPluginInfo.iconName == "book")
    #expect(BookPluginInfo.supportedExtensions.contains("m4b"))
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
