import Testing
import Foundation
import SwiftData
@testable import PluginAudio

@Test func audioPluginInfoExportsMetadata() {
    #expect(AudioPluginInfo.titleKey == "Music")
    #expect(AudioPluginInfo.maxAudioCount == 100)
    #expect(AudioPluginInfo.supportedExtensions.contains("mp3"))
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
