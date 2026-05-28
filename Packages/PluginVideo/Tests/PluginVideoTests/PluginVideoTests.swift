import PluginVideo
import SwiftUI
import Testing

@MainActor
@Test func videoViewsCanBeConstructed() {
    let file = URL(fileURLWithPath: "/tmp/sample.mov")
    _ = VideoDB(files: [file])
    _ = VideoGrid(files: [file])
}
