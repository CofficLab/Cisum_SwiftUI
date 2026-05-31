import Testing
import Foundation
import SwiftData
@testable import PluginAudio

@Test func audioPluginInfoExportsMetadata() {
    #expect(AudioPluginInfo.titleKey == "Music")
    #expect(AudioPluginInfo.maxAudioCount == 100)
    #expect(AudioPluginInfo.supportedExtensions.contains("mp3"))
}

@Test func audioPluginSupportsPlayerRecognizedAudioExtensions() {
    let playerAudioExtensions = ["mp3", "m4a", "aac", "wav", "aiff", "ogg", "opus", "flac", "alac"]

    for extensionName in playerAudioExtensions {
        #expect(AudioPluginInfo.supportedExtensions.contains(extensionName))
    }
}

@Test func missingStorageErrorKeepsStorageSetupGuidance() {
    let presentation = AudioRootErrorPresentation.make(error: .initialization(reason: "Storage 未找到"))

    #expect(presentation.title == "存储位置未设置")
    #expect(presentation.message == "请先设置媒体仓库的存储位置")
    #expect(presentation.detail == nil)
}

@Test func databaseInitializationErrorShowsActualFailure() {
    let presentation = AudioRootErrorPresentation.make(error: .initialization(reason: "database is locked"))

    #expect(presentation.title == "音频库初始化失败")
    #expect(presentation.message == "请尝试重启应用")
    #expect(presentation.detail == "初始化失败: database is locked")
}

@Test func audioDBNextOfReturnsFollowingOrderedTrack() async throws {
    let schema = Schema([AudioModel.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let db = AudioDB(container, reason: "audioDBNextOfReturnsFollowingOrderedTrack")

    let first = URL(fileURLWithPath: "/tmp/cisum-audio-tests/first.mp3")
    let second = URL(fileURLWithPath: "/tmp/cisum-audio-tests/second.mp3")

    await db.insertAudio(url: first, order: 10)
    await db.insertAudio(url: second, order: 20)

    let next = try await db.getNextAudioURLOf(first)
    #expect(next == second)
}

@Test func audioDBNextOfReturnsNilAtLastTrack() async throws {
    let schema = Schema([AudioModel.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let db = AudioDB(container, reason: "audioDBNextOfReturnsNilAtLastTrack")

    let first = URL(fileURLWithPath: "/tmp/cisum-audio-tests/first.mp3")
    let second = URL(fileURLWithPath: "/tmp/cisum-audio-tests/second.mp3")

    await db.insertAudio(url: first, order: 10)
    await db.insertAudio(url: second, order: 20)

    let next = try await db.getNextAudioURLOf(second)
    #expect(next == nil)
}

@Test func audioDBLastAudioReturnsHighestOrderedTrack() async throws {
    let schema = Schema([AudioModel.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let db = AudioDB(container, reason: "audioDBLastAudioReturnsHighestOrderedTrack")

    let first = URL(fileURLWithPath: "/tmp/cisum-audio-tests/first.mp3")
    let second = URL(fileURLWithPath: "/tmp/cisum-audio-tests/second.mp3")

    await db.insertAudio(url: first, order: 10)
    await db.insertAudio(url: second, order: 20)

    let last = try await db.lastAudioURL()
    #expect(last == second)
}

@Test func audioDBDeleteAudiosByURLRemovesFilesAndModels() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)

    let schema = Schema([AudioModel.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let db = AudioDB(container, reason: "audioDBDeleteAudiosByURLRemovesFilesAndModels")

    let file = root.appendingPathComponent("track.mp3")
    try Data("audio".utf8).write(to: file)
    await db.insertAudio(url: file, order: 10)

    try await db.deleteAudiosByURL(disk: root, urls: [file])

    #expect(FileManager.default.fileExists(atPath: file.path) == false)
    #expect(await db.getTotalOfAudio() == 0)
}

@Test func audioDBContainsHandlesRootAndSiblingPrefixPaths() {
    let root = URL(fileURLWithPath: "/", isDirectory: true)
    let rootChild = URL(fileURLWithPath: "/tmp/cisum-audio-tests/track.mp3")
    let disk = URL(fileURLWithPath: "/tmp/cisum-audio-tests/audio", isDirectory: true)
    let sibling = URL(fileURLWithPath: "/tmp/cisum-audio-tests/audio-backup/track.mp3")

    #expect(AudioDB.contains(root, audioURL: rootChild))
    #expect(!AudioDB.contains(disk, audioURL: sibling))
}

@Test func audioDBContainsResolvesSymlinkedLibraryRoots() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realDisk = root.appendingPathComponent("real-audio", isDirectory: true)
    let linkedDisk = root.appendingPathComponent("audio-link", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: realDisk, withIntermediateDirectories: true)
    try FileManager.default.createSymbolicLink(at: linkedDisk, withDestinationURL: realDisk)
    let audio = realDisk.appendingPathComponent("track.mp3")
    try Data("audio".utf8).write(to: audio)

    #expect(AudioDB.contains(linkedDisk, audioURL: audio))
}

@Test func audioDBDeleteAudiosByURLRejectsFilesOutsideLibrary() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let disk = root.appendingPathComponent("audio", isDirectory: true)
    let outside = root.appendingPathComponent("outside", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: disk, withIntermediateDirectories: true)
    try FileManager.default.createDirectory(at: outside, withIntermediateDirectories: true)

    let schema = Schema([AudioModel.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let db = AudioDB(container, reason: "audioDBDeleteAudiosByURLRejectsFilesOutsideLibrary")

    let file = outside.appendingPathComponent("track.mp3")
    try Data("audio".utf8).write(to: file)
    await db.insertAudio(url: file, order: 10)

    do {
        try await db.deleteAudiosByURL(disk: disk, urls: [file])
        Issue.record("Deleting a file outside the audio library should fail")
    } catch {
        #expect(error.localizedDescription.contains("outside the current library"))
    }
    #expect(FileManager.default.fileExists(atPath: file.path))
    #expect(await db.getTotalOfAudio() == 1)
}

@Test func audioDBDeleteAudiosByURLRejectsLibraryRoot() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)

    let schema = Schema([AudioModel.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let db = AudioDB(container, reason: "audioDBDeleteAudiosByURLRejectsLibraryRoot")

    await db.insertAudio(url: root, order: 10)

    do {
        try await db.deleteAudiosByURL(disk: root, urls: [root])
        Issue.record("Deleting the audio library root should fail")
    } catch {
        #expect(error.localizedDescription.contains("outside the current library"))
    }
    #expect(FileManager.default.fileExists(atPath: root.path))
    #expect(await db.getTotalOfAudio() == 1)
}

@Test func audioDBDeleteAudiosByURLRejectsMixedBatchBeforeDeleting() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let disk = root.appendingPathComponent("audio", isDirectory: true)
    let outside = root.appendingPathComponent("outside", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: disk, withIntermediateDirectories: true)
    try FileManager.default.createDirectory(at: outside, withIntermediateDirectories: true)

    let schema = Schema([AudioModel.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let db = AudioDB(container, reason: "audioDBDeleteAudiosByURLRejectsMixedBatchBeforeDeleting")

    let insideFile = disk.appendingPathComponent("inside.mp3")
    let outsideFile = outside.appendingPathComponent("outside.mp3")
    try Data("audio".utf8).write(to: insideFile)
    try Data("audio".utf8).write(to: outsideFile)
    await db.insertAudio(url: insideFile, order: 10)
    await db.insertAudio(url: outsideFile, order: 20)

    do {
        try await db.deleteAudiosByURL(disk: disk, urls: [insideFile, outsideFile])
        Issue.record("Deleting a mixed batch with a file outside the audio library should fail")
    } catch {
        #expect(error.localizedDescription.contains("outside the current library"))
    }
    #expect(FileManager.default.fileExists(atPath: insideFile.path))
    #expect(FileManager.default.fileExists(atPath: outsideFile.path))
    #expect(await db.getTotalOfAudio() == 2)
}

@Test func audioDBSyncAppendsNewFilesInStablePathOrder() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)

    let schema = Schema([AudioModel.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let db = AudioDB(container, reason: "audioDBSyncAppendsNewFilesInStablePathOrder")

    let existing = root.appendingPathComponent("00-existing.mp3")
    let second = root.appendingPathComponent("02-second.mp3")
    let first = root.appendingPathComponent("01-first.mp3")
    for file in [existing, second, first] {
        try Data("audio".utf8).write(to: file)
    }

    await db.insertAudio(url: existing, order: 10)
    await db.syncWithUpdatedItems([second, first])

    #expect(await db.allAudioURLs(reason: "test") == [existing, first, second])
}

@Test func audioDBSyncIgnoresFoldersAndUnsupportedFiles() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)

    let schema = Schema([AudioModel.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let db = AudioDB(container, reason: "audioDBSyncIgnoresFoldersAndUnsupportedFiles")

    let folder = root.appendingPathComponent("folder", isDirectory: true)
    let notes = root.appendingPathComponent("notes.txt")
    let audio = root.appendingPathComponent("track.mp3")

    try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    try Data("notes".utf8).write(to: notes)
    try Data("audio".utf8).write(to: audio)

    await db.syncWithUpdatedItems([folder, notes, audio])
    #expect(await db.allAudioURLs(reason: "test") == [audio])

    await db.initItems([folder, notes, audio])
    #expect(await db.allAudioURLs(reason: "test") == [audio])
}

@Test func audioDBFullSyncRepairsDuplicateLegacyAudioOrders() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)

    let schema = Schema([AudioModel.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let db = AudioDB(container, reason: "audioDBFullSyncRepairsDuplicateLegacyAudioOrders")

    let second = root.appendingPathComponent("02-second.mp3")
    let first = root.appendingPathComponent("01-first.mp3")
    for file in [second, first] {
        try Data("audio".utf8).write(to: file)
        await db.insertAudio(url: file, order: 0)
    }

    await db.initItems([second, first])

    #expect(await db.allAudioURLs(reason: "test") == [first, second])
}

@Test func audioDBKeepsUniqueExistingAudioOrders() {
    #expect(!AudioDB.needsStableOrderRepair([20, 10, 30]))
    #expect(!AudioDB.needsStableOrderRepair([-1, -1, 10]))
    #expect(AudioDB.needsStableOrderRepair([0, 0]))
}
