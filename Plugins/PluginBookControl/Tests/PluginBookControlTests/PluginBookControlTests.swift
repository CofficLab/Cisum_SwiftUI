import Testing
import SwiftUI
@testable import PluginBookControl

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(BookControlPluginInfo.iconName == "playpause")
    #expect(BookControlPluginInfo.order == 8)
}

@Test func repeatAllWrapsBookChapterNavigation() {
    let chapters = [
        URL(fileURLWithPath: "/tmp/book/001.m4b"),
        URL(fileURLWithPath: "/tmp/book/002.m4b"),
        URL(fileURLWithPath: "/tmp/book/003.m4b"),
    ]

    let next = BookControlRootView<EmptyView>.adjacentAsset(
        in: chapters,
        current: chapters[2],
        offset: 1,
        playMode: .repeatAll
    )
    let previous = BookControlRootView<EmptyView>.adjacentAsset(
        in: chapters,
        current: chapters[0],
        offset: -1,
        playMode: .repeatAll
    )
    let sequenceNext = BookControlRootView<EmptyView>.adjacentAsset(
        in: chapters,
        current: chapters[2],
        offset: 1,
        playMode: .sequence
    )

    #expect(next == chapters[0])
    #expect(previous == chapters[2])
    #expect(sequenceNext == nil)
}
