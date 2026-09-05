import Foundation
import CisumUIComponents
import SwiftUI

enum BookLikeStatusChangePolicy {
    static func shouldAcceptChange(isSceneActive: Bool) -> Bool {
        isSceneActive
    }
}

public struct BookLikeRootView<Content>: View, SuperLog where Content: View {
    public nonisolated static var emoji: String { BookLikePluginInfo.emoji }
    private let verbose = false

    @ObservedObject private var viewModel: BookLikeViewModel

    private let content: Content

    init(
        viewModel: BookLikeViewModel,
        @ViewBuilder content: () -> Content
    ) {
        self.viewModel = viewModel
        self.content = content()
    }

    public var body: some View {
        content
    }
}
