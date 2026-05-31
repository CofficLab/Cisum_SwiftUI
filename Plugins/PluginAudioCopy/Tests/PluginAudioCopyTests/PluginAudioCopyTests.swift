import Foundation
import SwiftUI
import Testing
@testable import PluginAudioCopy

@Test func audioCopyInfoExportsMetadata() {
    #expect(AudioCopyPluginInfo.iconName == "music.note")
    #expect(AudioCopyPluginInfo.table == "Audio-Copy-macOS")
}

#if os(macOS)
@MainActor
@Test func copyTaskCountNotificationPostsSynchronouslyOnMainThread() {
    let receivedCount = TestNotificationValue<Int?>(nil)
    let token = NotificationCenter.default.addObserver(
        forName: .copyTaskCountChanged,
        object: nil,
        queue: nil
    ) { notification in
        receivedCount.set(notification.userInfo?["count"] as? Int)
    }
    defer { NotificationCenter.default.removeObserver(token) }

    NotificationCenter.postCopyTaskCountChanged(count: 3)

    #expect(receivedCount.value == 3)
}

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

@Test func copyDropDeduplicatesSymlinkedAudioSources() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    let realFile = root.appendingPathComponent("real.mp3")
    let linkedFile = root.appendingPathComponent("linked.mp3")
    let unsupported = root.appendingPathComponent("notes.txt")
    try Data("audio".utf8).write(to: realFile)
    try Data("notes".utf8).write(to: unsupported)
    try FileManager.default.createSymbolicLink(at: linkedFile, withDestinationURL: realFile)

    #expect(CopyRootView<EmptyView>.representsSameCopySource(realFile, linkedFile))
    #expect(CopyRootView<EmptyView>.canonicalCopySourceIdentity(for: realFile) == CopyRootView<EmptyView>.canonicalCopySourceIdentity(for: linkedFile))
    #expect(CopyRootView<EmptyView>.uniqueSupportedAudioSources([
        linkedFile,
        unsupported,
        realFile,
    ]) == [linkedFile])
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

@Test func copyWorkerAvoidsDanglingSymlinkDestinationNames() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    try FileManager.default.createSymbolicLink(
        at: root.appendingPathComponent("track.mp3"),
        withDestinationURL: root.appendingPathComponent("missing.mp3")
    )

    let tasks = [
        CopyTaskDTO(bookmark: Data([0]), destination: root, originalFilename: "track.mp3"),
    ]

    let destinations = CopyWorker.makeUniqueDestinationURLs(for: tasks)

    #expect(destinations.map(\.lastPathComponent) == ["track 2.mp3"])
}

@Test func copyWorkerCopiesResolvedSymlinkTarget() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    let external = root.appendingPathComponent("external", isDirectory: true)
    try FileManager.default.createDirectory(at: external, withIntermediateDirectories: true)
    let realFile = external.appendingPathComponent("real.mp3")
    let linkedFile = root.appendingPathComponent("linked.mp3")
    try Data("audio".utf8).write(to: realFile)
    try FileManager.default.createSymbolicLink(at: linkedFile, withDestinationURL: realFile)

    #expect(CopyWorker.copySourceURL(for: linkedFile).standardizedFileURL == realFile.standardizedFileURL)
    #expect(CopyWorker.copySourceURL(for: realFile).standardizedFileURL == realFile.standardizedFileURL)
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

@Test func copyDropSkipsNoFilesAlertAfterPreparationFailure() {
    let error = NSError(domain: "AudioCopyDrop", code: 1)

    #expect(CopyRootView<EmptyView>.shouldShowNoFilesAdded(taskCount: 0, preparationErrors: [error]) == false)
    #expect(CopyRootView<EmptyView>.shouldShowNoFilesAdded(taskCount: 0, preparationErrors: []) == true)
    #expect(CopyRootView<EmptyView>.shouldShowNoFilesAdded(taskCount: 1, preparationErrors: [error]) == false)
}

@Test func copyDropOnlyChecksCopyServicesAfterFindingSources() {
    #expect(CopyRootView<EmptyView>.shouldPrepareCopyInfrastructure(sourceCount: 1))
    #expect(!CopyRootView<EmptyView>.shouldPrepareCopyInfrastructure(sourceCount: 0))
}

@Test func copyWorkerOnlyPostsFinishedWhenQueueIsStillEmpty() {
    let folder = URL(fileURLWithPath: "/tmp/cisum-audio-copy-tests", isDirectory: true)
    let task = CopyTaskDTO(bookmark: Data([0]), destination: folder, originalFilename: "new.mp3")

    #expect(CopyWorker.shouldPostFinished(afterDelayRemainingTasks: []))
    #expect(!CopyWorker.shouldPostFinished(afterDelayRemainingTasks: [task]))
}

@Test func copyWorkerSkipsTasksDeletedBeforeTheyStart() {
    #expect(CopyWorker.shouldStartTask(isTaskStillQueued: true))
    #expect(!CopyWorker.shouldStartTask(isTaskStillQueued: false))
}

@Test func copyWorkerDiscardsCompletedCopyWhenTaskWasDeleted() {
    #expect(CopyWorker.shouldKeepCompletedCopy(isTaskStillQueued: true))
    #expect(!CopyWorker.shouldKeepCompletedCopy(isTaskStillQueued: false))
}

private final class TestNotificationValue<Value>: @unchecked Sendable {
    private let lock = NSLock()
    private var storedValue: Value

    init(_ value: Value) {
        self.storedValue = value
    }

    var value: Value {
        lock.withLock { storedValue }
    }

    func set(_ value: Value) {
        lock.withLock {
            storedValue = value
        }
    }
}
#endif
