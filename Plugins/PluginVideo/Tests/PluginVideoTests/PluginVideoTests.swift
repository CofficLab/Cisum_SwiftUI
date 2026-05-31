@testable import PluginVideo
import SwiftUI
import Testing

@MainActor
@Test func videoViewsCanBeConstructed() {
    let file = URL(fileURLWithPath: "/tmp/sample.mov")
    _ = VideoDB(files: [file])
    _ = VideoGrid(files: [file])
}

@Test func videoTileOnlyAppliesCurrentFileSize() {
    let first = URL(fileURLWithPath: "/tmp/cisum-video-tests/first.mov")
    let second = URL(fileURLWithPath: "/tmp/cisum-video-tests/second.mov")

    #expect(VideoFileSizeLoadPolicy.shouldApplySize(currentFile: first, requestedFile: first))
    #expect(!VideoFileSizeLoadPolicy.shouldApplySize(currentFile: second, requestedFile: first))
}

@Test func videoTileAppliesFileSizeForSymlinkedCurrentFile() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realFile = root.appendingPathComponent("real.mov")
    let linkedFile = root.appendingPathComponent("linked.mov")
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    try Data("video".utf8).write(to: realFile)
    try FileManager.default.createSymbolicLink(at: linkedFile, withDestinationURL: realFile)

    #expect(VideoFileSizeLoadPolicy.shouldApplySize(
        currentFile: realFile,
        requestedFile: linkedFile
    ))
}
