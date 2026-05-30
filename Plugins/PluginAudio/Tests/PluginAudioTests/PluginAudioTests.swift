import Testing
import Foundation
import SwiftData
@testable import PluginAudio

@Test func audioPluginInfoExportsMetadata() {
    #expect(AudioPluginInfo.titleKey == "Music")
    #expect(AudioPluginInfo.maxAudioCount == 100)
    #expect(AudioPluginInfo.supportedExtensions.contains("mp3"))
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
