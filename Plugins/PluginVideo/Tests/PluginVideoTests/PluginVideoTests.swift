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
