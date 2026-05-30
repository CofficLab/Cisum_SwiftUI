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
