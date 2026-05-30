import Foundation
import SwiftUI
import Testing
@testable import PluginAudioCopy

@Test func audioCopyInfoExportsMetadata() {
    #expect(AudioCopyPluginInfo.iconName == "music.note")
    #expect(AudioCopyPluginInfo.table == "Audio-Copy-macOS")
}

#if os(macOS)
@Test func copyDropAcceptsOnlySupportedAudioFiles() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    let supportedAudio = root.appendingPathComponent("song.MP3")
    let unsupportedFile = root.appendingPathComponent("notes.txt")
    let folder = root.appendingPathComponent("album", isDirectory: true)

    try Data("audio".utf8).write(to: supportedAudio)
    try Data("notes".utf8).write(to: unsupportedFile)
    try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

    #expect(CopyRootView<EmptyView>.isSupportedAudioFile(supportedAudio))
    #expect(!CopyRootView<EmptyView>.isSupportedAudioFile(unsupportedFile))
    #expect(!CopyRootView<EmptyView>.isSupportedAudioFile(folder))
}

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

@Test func copyStateMessageDistinguishesPendingAndFailedTasks() {
    #expect(CopyStatePresentation.message(pendingCount: 2, failedCount: 0) == "正在复制 2 个文件")
    #expect(CopyStatePresentation.message(pendingCount: 0, failedCount: 1) == "1 个复制任务失败")
    #expect(CopyStatePresentation.message(pendingCount: 2, failedCount: 1) == "正在复制 2 个文件，1 个失败")
    #expect(CopyStatePresentation.message(pendingCount: 0, failedCount: 0).isEmpty)
}

@MainActor @Test func copyListRejectsStaleDeleteOffsets() {
    let folder = URL(fileURLWithPath: "/tmp/cisum-audio-copy-tests", isDirectory: true)
    let tasks = [
        CopyTask(bookmark: Data([0]), destination: folder, originalFilename: "one.mp3"),
        CopyTask(bookmark: Data([1]), destination: folder, originalFilename: "two.mp3"),
    ]

    #expect(CopyList.tasksToDelete(from: IndexSet(integer: 1), in: tasks)?.map(\.originalFilename) == ["two.mp3"])
    #expect(CopyList.tasksToDelete(from: IndexSet(integer: 2), in: tasks) == nil)
}

@MainActor @Test func copyTaskMessageShowsQueuedRunningAndFailedStates() {
    let task = CopyTask(
        bookmark: Data([0]),
        destination: URL(fileURLWithPath: "/tmp/cisum-audio-copy-tests", isDirectory: true),
        originalFilename: "one.mp3"
    )

    #expect(task.message == "等待复制")

    task.isRunning = true
    #expect(task.message == "进行中")

    task.isRunning = false
    task.error = "Permission denied"
    #expect(task.message == "Permission denied")
}

@Test func copyLimitCountsCurrentLibraryAndIncomingDrop() {
    #expect(AudioCopyLimitPolicy.allowedTaskCount(
        currentAudioCount: 99,
        requestedTaskCount: 10,
        maxAudioCount: 100,
        isFreeVersion: true
    ) == 1)

    #expect(AudioCopyLimitPolicy.allowedTaskCount(
        currentAudioCount: 100,
        requestedTaskCount: 10,
        maxAudioCount: 100,
        isFreeVersion: true
    ) == 0)

    #expect(AudioCopyLimitPolicy.allowedTaskCount(
        currentAudioCount: 100,
        requestedTaskCount: 10,
        maxAudioCount: 100,
        isFreeVersion: false
    ) == 10)
}
#endif
