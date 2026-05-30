import Foundation
@testable import PluginBookProgress
import Testing

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(BookProgressPluginInfo.iconName == "book.closed")
    #expect(BookProgressPluginInfo.order == 5)
}

@Test func currentURLChangesDoNotOverwriteSavedPlaybackTime() {
    let url = URL(fileURLWithPath: "/tmp/book/chapter-01.mp3")

    let snapshot = BookProgressPersistencePolicy.currentURLChangeSnapshot(currentURL: url)

    #expect(snapshot == BookProgressStateSnapshot(currentURL: url, time: nil))
}

@Test func clearingCurrentURLClearsGlobalBookWithoutSavingChapterState() {
    let snapshot = BookProgressPersistencePolicy.currentURLChangeSnapshot(currentURL: nil)

    #expect(snapshot == nil)
}

@Test func playbackPositionChangesPersistCurrentTime() {
    let url = URL(fileURLWithPath: "/tmp/book/chapter-01.mp3")

    let snapshot = BookProgressPersistencePolicy.snapshot(
        currentURL: url,
        currentTime: 42,
        trigger: .playbackPositionChanged
    )

    #expect(snapshot == BookProgressStateSnapshot(currentURL: url, time: 42))
}
