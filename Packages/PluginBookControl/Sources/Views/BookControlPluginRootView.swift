import CisumUIComponents
import SwiftUI

struct BookControlPluginRootView<Content>: View where Content: View {
    private let viewModel: BookControlViewModel
    private let content: Content

    init(viewModel: BookControlViewModel, @ViewBuilder content: () -> Content) {
        self.viewModel = viewModel
        self.content = content()
    }

    var body: some View {
        BookControlRootView(
            viewModel: viewModel
        ) {
            content
        }
    }
}
