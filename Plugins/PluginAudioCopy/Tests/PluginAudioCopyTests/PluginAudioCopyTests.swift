import Foundation
import Testing
@testable import PluginAudioCopy

@Test func audioCopyInfoExportsMetadata() {
    #expect(AudioCopyPluginInfo.iconName == "music.note")
    #expect(AudioCopyPluginInfo.table == "Audio-Copy-macOS")
}

#if os(macOS)
@Test func copyWorkerPlansUniqueDestinationNames() {
    let folder = URL(fileURLWithPath: "/tmp/cisum-audio-copy-tests", isDirectory: true)
    let existingPath = folder.appendingPathComponent("track.mp3").path
    let tasks = [
        CopyTaskDTO(bookmark: Data([0]), destination: folder, originalFilename: "track.mp3"),
        CopyTaskDTO(bookmark: Data([1]), destination: folder, originalFilename: "track.mp3"),
        CopyTaskDTO(bookmark: Data([2]), destination: folder, originalFilename: "chapter"),
        CopyTaskDTO(bookmark: Data([3]), destination: folder, originalFilename: "chapter"),
    ]

    let destinations = CopyWorker.makeUniqueDestinationURLs(for: tasks) { url in
        url.path == existingPath
    }

    #expect(destinations.map(\.lastPathComponent) == [
        "track 2.mp3",
        "track 3.mp3",
        "chapter",
        "chapter 2",
    ])
}
#endif
