import Testing
@testable import PluginAudioDBView
import Foundation
import UniformTypeIdentifiers

@Test func audioDBInfoExportsMetadata() {
    #expect(AudioDBPluginInfo.titleKey == "Audio Repository")
    #expect(AudioDBPluginInfo.table == "Audio-DBView")
}

@Test func audioImportCleansCopiedFilesWhenBatchFails() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let sourceRoot = root.appendingPathComponent("source", isDirectory: true)
    let destinationRoot = root.appendingPathComponent("destination", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: sourceRoot, withIntermediateDirectories: true)
    let validSource = sourceRoot.appendingPathComponent("valid.mp3")
    let missingSource = sourceRoot.appendingPathComponent("missing.mp3")
    try Data("audio".utf8).write(to: validSource)

    await #expect(throws: Error.self) {
        try await AudioDBView.copyFilesInBackground([validSource, missingSource], to: destinationRoot)
    }

    #expect(FileManager.default.fileExists(atPath: destinationRoot.appendingPathComponent("valid.mp3").path) == false)
}

@Test func audioImportCleansCopiedFilesWhenRepositoryIsUnavailable() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    let copiedFile = root.appendingPathComponent("orphaned.mp3")
    try Data("audio".utf8).write(to: copiedFile)

    AudioDBView.cleanUpCopiedFiles([copiedFile])

    #expect(FileManager.default.fileExists(atPath: copiedFile.path) == false)
}

@Test func audioImportCopiesSymlinkedFilesAsStandaloneFiles() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let sourceRoot = root.appendingPathComponent("source", isDirectory: true)
    let destinationRoot = root.appendingPathComponent("destination", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: sourceRoot, withIntermediateDirectories: true)
    let realSource = sourceRoot.appendingPathComponent("real.mp3")
    let linkedSource = sourceRoot.appendingPathComponent("linked.mp3")
    try Data("audio".utf8).write(to: realSource)
    try FileManager.default.createSymbolicLink(at: linkedSource, withDestinationURL: realSource)

    let copiedFiles = try await AudioDBView.copyFilesInBackground([linkedSource], to: destinationRoot)
    let copiedFile = try #require(copiedFiles.first)
    let fileType = try FileManager.default.attributesOfItem(atPath: copiedFile.path)[.type] as? FileAttributeType

    #expect(copiedFile.lastPathComponent == "linked.mp3")
    #expect(fileType == .typeRegular)
    #expect((try Data(contentsOf: copiedFile)) == Data("audio".utf8))
}

@Test func audioImportAvoidsDanglingSymlinkDestinationNames() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let sourceRoot = root.appendingPathComponent("source", isDirectory: true)
    let destinationRoot = root.appendingPathComponent("destination", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: sourceRoot, withIntermediateDirectories: true)
    try FileManager.default.createDirectory(at: destinationRoot, withIntermediateDirectories: true)
    let source = sourceRoot.appendingPathComponent("track.mp3")
    let danglingDestination = destinationRoot.appendingPathComponent("track.mp3")
    try Data("audio".utf8).write(to: source)
    try FileManager.default.createSymbolicLink(
        at: danglingDestination,
        withDestinationURL: destinationRoot.appendingPathComponent("missing.mp3")
    )

    let copiedFiles = try await AudioDBView.copyFilesInBackground([source], to: destinationRoot)
    let copiedFile = try #require(copiedFiles.first)

    #expect(copiedFile.lastPathComponent == "track 2.mp3")
    #expect((try Data(contentsOf: copiedFile)) == Data("audio".utf8))
    #expect((try? danglingDestination.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink) == true)
}

@Test func audioListRejectsStaleDeleteOffsets() {
    let root = URL(fileURLWithPath: "/tmp/cisum-audio-list-tests", isDirectory: true)
    let urls = [
        root.appendingPathComponent("one.mp3"),
        root.appendingPathComponent("two.mp3"),
    ]

    #expect(AudioList.urlsToDelete(from: IndexSet(integer: 1), in: urls) == [urls[1]])
    #expect(AudioList.urlsToDelete(from: IndexSet(integer: 2), in: urls) == nil)
}

@Test func audioListLoadsMoreFromCurrentLoadedCount() {
    #expect(AudioList.nextLoadOffset(loadedCount: 90) == 90)
    #expect(AudioList.nextLoadOffset(loadedCount: 100) == 100)
}

@Test func audioListOnlyAppliesCurrentLoadGeneration() {
    #expect(AudioListLoadPolicy.shouldApplyResult(currentGeneration: 2, resultGeneration: 2))
    #expect(!AudioListLoadPolicy.shouldApplyResult(currentGeneration: 3, resultGeneration: 2))
}

@Test func audioListLoadMoreDeduplicatesSymlinkedRows() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realFile = root.appendingPathComponent("real.mp3")
    let linkedFile = root.appendingPathComponent("linked.mp3")
    let otherFile = root.appendingPathComponent("other.mp3")
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    try Data("audio".utf8).write(to: realFile)
    try Data("other".utf8).write(to: otherFile)
    try FileManager.default.createSymbolicLink(at: linkedFile, withDestinationURL: realFile)

    #expect(AudioListLoadPolicy.uniqueAdditionalURLs(
        existingURLs: [linkedFile],
        newURLs: [realFile, otherFile, otherFile]
    ) == [otherFile])
}

@Test func audioListLoadMoreTracksFetchedPageSizeAfterDeduplication() {
    #expect(AudioListLoadPolicy.hasMoreAfterLoading(fetchedCount: 50, pageSize: 50))
    #expect(!AudioListLoadPolicy.hasMoreAfterLoading(fetchedCount: 49, pageSize: 50))
}

@Test func staleAudioListResultsKeepCurrentLoadingState() {
    #expect(AudioListLoadPolicy.shouldKeepLoadingStateWhenDiscardingStaleResult(
        currentGeneration: 3,
        resultGeneration: 2
    ))
    #expect(!AudioListLoadPolicy.shouldKeepLoadingStateWhenDiscardingStaleResult(
        currentGeneration: 2,
        resultGeneration: 2
    ))
}

@Test func audioListDeletionMatchesSymlinkedRows() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realFile = root.appendingPathComponent("real.mp3")
    let linkedFile = root.appendingPathComponent("linked.mp3")
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    try Data("audio".utf8).write(to: realFile)
    try FileManager.default.createSymbolicLink(at: linkedFile, withDestinationURL: realFile)

    #expect(AudioListDeletionPolicy.shouldRemove(realFile, deletedURLs: [linkedFile]))
    #expect(AudioListDeletionPolicy.shouldRemove(linkedFile, deletedURLs: [realFile]))
    #expect(!AudioListDeletionPolicy.shouldRemove(
        root.appendingPathComponent("other.mp3"),
        deletedURLs: [linkedFile]
    ))
}

@Test func audioListDeletionCountsOnlyDisplayedRemovedRows() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realFile = root.appendingPathComponent("real.mp3")
    let linkedFile = root.appendingPathComponent("linked.mp3")
    let otherFile = root.appendingPathComponent("other.mp3")
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    try Data("audio".utf8).write(to: realFile)
    try FileManager.default.createSymbolicLink(at: linkedFile, withDestinationURL: realFile)

    #expect(AudioListDeletionPolicy.removedDisplayedCount(
        from: [realFile, otherFile],
        deletedURLs: [linkedFile, realFile]
    ) == 1)
}

@Test func audioListDeletionUpdatesTotalForUnloadedDeletedRows() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realFile = root.appendingPathComponent("real.mp3")
    let linkedFile = root.appendingPathComponent("linked.mp3")
    let unloadedFile = root.appendingPathComponent("unloaded.mp3")
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    try Data("audio".utf8).write(to: realFile)
    try Data("audio".utf8).write(to: unloadedFile)
    try FileManager.default.createSymbolicLink(at: linkedFile, withDestinationURL: realFile)

    #expect(AudioListDeletionPolicy.removedDisplayedCount(
        from: [realFile],
        deletedURLs: [unloadedFile]
    ) == 0)
    #expect(AudioListDeletionPolicy.totalCountAfterDeletion(
        currentTotal: 10,
        deletedURLs: [unloadedFile]
    ) == 9)
    #expect(AudioListDeletionPolicy.totalCountAfterDeletion(
        currentTotal: 10,
        deletedURLs: [realFile, linkedFile, unloadedFile]
    ) == 8)
    #expect(AudioListDeletionPolicy.totalCountAfterDeletion(
        currentTotal: 1,
        deletedURLs: [realFile, unloadedFile]
    ) == 0)
}

@Test func audioListOnlyAppliesCurrentSelectionPlayback() {
    let first = URL(fileURLWithPath: "/tmp/cisum-audio-selection/first.mp3")
    let second = URL(fileURLWithPath: "/tmp/cisum-audio-selection/second.mp3")

    #expect(AudioListSelectionPolicy.shouldApplySelection(
        currentGeneration: 2,
        requestGeneration: 2,
        requestedURL: first,
        selection: first,
        displayedURLs: [first, second]
    ))
    #expect(!AudioListSelectionPolicy.shouldApplySelection(
        currentGeneration: 3,
        requestGeneration: 2,
        requestedURL: first,
        selection: first,
        displayedURLs: [first, second]
    ))
    #expect(!AudioListSelectionPolicy.shouldApplySelection(
        currentGeneration: 2,
        requestGeneration: 2,
        requestedURL: first,
        selection: second,
        displayedURLs: [first, second]
    ))
    #expect(!AudioListSelectionPolicy.shouldApplySelection(
        currentGeneration: 2,
        requestGeneration: 2,
        requestedURL: first,
        selection: first,
        displayedURLs: [second]
    ))
}

@Test func audioListSelectionTreatsSymlinkedAudioAsSameFile() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realFile = root.appendingPathComponent("real.mp3")
    let linkedFile = root.appendingPathComponent("linked.mp3")
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    try Data("audio".utf8).write(to: realFile)
    try FileManager.default.createSymbolicLink(at: linkedFile, withDestinationURL: realFile)

    #expect(AudioListSelectionPolicy.shouldApplySelection(
        currentGeneration: 2,
        requestGeneration: 2,
        requestedURL: linkedFile,
        selection: realFile,
        displayedURLs: [realFile]
    ))
    #expect(AudioListSelectionPolicy.representsSameAudio(realFile, linkedFile))
    #expect(AudioListSelectionPolicy.representsSameAudio(nil, nil))
    #expect(!AudioListSelectionPolicy.representsSameAudio(realFile, nil))
    #expect(!AudioListSelectionPolicy.representsSameAudio(
        realFile,
        root.appendingPathComponent("other.mp3")
    ))
}

@Test func audioDeleteOnlyResetsPlaybackForStillCurrentDeletedAudio() {
    let root = URL(fileURLWithPath: "/tmp/cisum-audio-delete-tests", isDirectory: true)
    let deleted = root.appendingPathComponent("deleted.mp3")
    let unstandardizedDeleted = root
        .appendingPathComponent("nested", isDirectory: true)
        .appendingPathComponent("..", isDirectory: true)
        .appendingPathComponent("deleted.mp3")
    let switched = root.appendingPathComponent("switched.mp3")

    #expect(AudioDeletePlaybackPolicy.deletedURLsContainCurrentAudio(
        currentURL: deleted,
        deletedURLs: [deleted]
    ))
    #expect(AudioDeletePlaybackPolicy.deletedURLsContainCurrentAudio(
        currentURL: deleted,
        deletedURLs: [unstandardizedDeleted]
    ))
    #expect(!AudioDeletePlaybackPolicy.deletedURLsContainCurrentAudio(
        currentURL: switched,
        deletedURLs: [deleted]
    ))
    #expect(!AudioDeletePlaybackPolicy.deletedURLsContainCurrentAudio(
        currentURL: nil,
        deletedURLs: [deleted]
    ))
    #expect(!AudioDeletePlaybackPolicy.shouldResetDirectlyAfterDelete(
        currentURL: deleted,
        deletedURLs: [deleted],
        isPlaybackControllerHandlingDeletion: true
    ))
    #expect(AudioDeletePlaybackPolicy.shouldResetDirectlyAfterDelete(
        currentURL: deleted,
        deletedURLs: [deleted],
        isPlaybackControllerHandlingDeletion: false
    ))
}

@Test func audioDeleteResetsPlaybackForSymlinkedCurrentAudio() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realFile = root.appendingPathComponent("real.mp3")
    let linkedFile = root.appendingPathComponent("linked.mp3")
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    try Data("audio".utf8).write(to: realFile)
    try FileManager.default.createSymbolicLink(at: linkedFile, withDestinationURL: realFile)

    #expect(AudioDeletePlaybackPolicy.deletedURLsContainCurrentAudio(
        currentURL: realFile,
        deletedURLs: [linkedFile]
    ))
}

@Test func audioItemOnlyAppliesCurrentFileSize() {
    let root = URL(fileURLWithPath: "/tmp/cisum-audio-item-tests", isDirectory: true)
    let first = root.appendingPathComponent("first.mp3")
    let second = root.appendingPathComponent("second.mp3")

    #expect(AudioItemFileSizeLoadPolicy.shouldApplySize(currentURL: first, requestedURL: first))
    #expect(!AudioItemFileSizeLoadPolicy.shouldApplySize(currentURL: second, requestedURL: first))
}

@Test func audioItemAppliesFileSizeForSymlinkedCurrentFile() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realFile = root.appendingPathComponent("real.mp3")
    let linkedFile = root.appendingPathComponent("linked.mp3")
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    try Data("audio".utf8).write(to: realFile)
    try FileManager.default.createSymbolicLink(at: linkedFile, withDestinationURL: realFile)

    #expect(AudioItemFileSizeLoadPolicy.shouldApplySize(
        currentURL: realFile,
        requestedURL: linkedFile
    ))
}

@Test func audioItemExportUsesHumanNumberingForDuplicateDownloads() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    let existing = root.appendingPathComponent("track.mp3")
    try Data("audio".utf8).write(to: existing)

    let source = URL(fileURLWithPath: "/tmp/source/track.mp3")
    let destination = AudioItemView.uniqueDestination(for: source, in: root)

    #expect(destination.lastPathComponent == "track 2.mp3")
}

@Test func audioItemExportAvoidsDanglingSymlinkDestinationNames() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    let danglingDestination = root.appendingPathComponent("track.mp3")
    try FileManager.default.createSymbolicLink(
        at: danglingDestination,
        withDestinationURL: root.appendingPathComponent("missing.mp3")
    )

    let source = URL(fileURLWithPath: "/tmp/source/track.mp3")
    let destination = AudioItemView.uniqueDestination(for: source, in: root)

    #expect(destination.lastPathComponent == "track 2.mp3")
}

@Test func audioItemRevealInFinderRequiresExistingPathEntry() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    let existingFile = root.appendingPathComponent("track.mp3")
    let danglingLink = root.appendingPathComponent("dangling.mp3")
    let missingFile = root.appendingPathComponent("missing.mp3")

    try Data("audio".utf8).write(to: existingFile)
    try FileManager.default.createSymbolicLink(
        at: danglingLink,
        withDestinationURL: root.appendingPathComponent("deleted-target.mp3")
    )

    #expect(AudioItemFileActionPolicy.canRevealInFinder(existingFile))
    #expect(AudioItemFileActionPolicy.canRevealInFinder(danglingLink))
    #expect(!AudioItemFileActionPolicy.canRevealInFinder(missingFile))
}

@Test func audioItemExportCopiesSymlinkedFilesAsStandaloneFiles() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let sourceRoot = root.appendingPathComponent("source", isDirectory: true)
    let downloadsRoot = root.appendingPathComponent("downloads", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: sourceRoot, withIntermediateDirectories: true)
    try FileManager.default.createDirectory(at: downloadsRoot, withIntermediateDirectories: true)
    let realSource = sourceRoot.appendingPathComponent("real.mp3")
    let linkedSource = sourceRoot.appendingPathComponent("linked.mp3")
    try Data("audio".utf8).write(to: realSource)
    try FileManager.default.createSymbolicLink(at: linkedSource, withDestinationURL: realSource)

    let copiedFile = try await AudioItemView.copyToDownloads(linkedSource, downloadsURL: downloadsRoot)
    let fileType = try FileManager.default.attributesOfItem(atPath: copiedFile.path)[.type] as? FileAttributeType

    #expect(copiedFile.lastPathComponent == "linked.mp3")
    #expect(fileType == .typeRegular)
    #expect((try Data(contentsOf: copiedFile)) == Data("audio".utf8))
}

@Test func audioImportFiltersUnsupportedDroppedItems() {
    let root = URL(fileURLWithPath: "/tmp/cisum-audio-import-filter-tests", isDirectory: true)
    let supported = root.appendingPathComponent("track.MP3")
    let unsupported = root.appendingPathComponent("notes.txt")
    let folder = root.appendingPathComponent("folder", isDirectory: true)

    #expect(AudioDBView.supportedImportURLs(
        from: [supported, unsupported, folder],
        supportedExtensions: ["mp3", "wav"]
    ) == [supported])
}

@Test func audioImportDeduplicatesSymlinkedImportSources() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realFile = root.appendingPathComponent("real.mp3")
    let linkedFile = root.appendingPathComponent("linked.mp3")
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    try Data("audio".utf8).write(to: realFile)
    try FileManager.default.createSymbolicLink(at: linkedFile, withDestinationURL: realFile)

    #expect(AudioDBView.representsSameImportSource(realFile, linkedFile))
    #expect(AudioDBView.canonicalImportSourceIdentity(for: realFile) == AudioDBView.canonicalImportSourceIdentity(for: linkedFile))
    #expect(AudioDBView.supportedImportURLs(
        from: [linkedFile, realFile],
        supportedExtensions: ["mp3"]
    ) == [linkedFile])
}

@Test func audioDropReadsFileURLDataProvider() async throws {
    let expected = URL(fileURLWithPath: "/tmp/cisum-audio-drop-provider-tests/track.mp3")
    let provider = NSItemProvider()
    provider.registerDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier, visibility: .all) { completion in
        completion(expected.dataRepresentation, nil)
        return nil
    }

    let url = try await AudioDBView.droppedFileURL(from: provider)

    #expect(url == expected)
}

@Test func audioDropSkipsEmptyImportAfterProviderFailure() {
    let error = NSError(domain: "AudioDrop", code: 1)
    let url = URL(fileURLWithPath: "/tmp/cisum-audio-drop-provider-tests/track.mp3")

    #expect(AudioDBView.shouldImportDroppedURLs([], after: [error]) == false)
    #expect(AudioDBView.shouldImportDroppedURLs([url], after: [error]) == true)
    #expect(AudioDBView.shouldImportDroppedURLs([], after: []) == false)
}

@Test func audioImportDoesNotStartWhileAlreadyImporting() {
    #expect(AudioDBView.shouldStartImport(isImporting: false))
    #expect(!AudioDBView.shouldStartImport(isImporting: true))
}

@Test func audioImportAllowsReadableLocalFilesWithoutSecurityScope() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    let readableFile = root.appendingPathComponent("track.mp3")
    let missingFile = root.appendingPathComponent("missing.mp3")
    try Data("audio".utf8).write(to: readableFile)

    #expect(AudioDBView.hasImportSourceAccess(readableFile, securityScopeGranted: false))
    #expect(AudioDBView.hasImportSourceAccess(missingFile, securityScopeGranted: true))
    #expect(!AudioDBView.hasImportSourceAccess(missingFile, securityScopeGranted: false))
}
