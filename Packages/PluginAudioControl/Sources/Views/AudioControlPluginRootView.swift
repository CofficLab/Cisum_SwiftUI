import CisumUIComponents
import PluginAudio
import SwiftUI

struct AudioControlPluginRootView<Content>: View where Content: View {
    private let viewModel: AudioControlViewModel
    private let content: Content

    init(viewModel: AudioControlViewModel, @ViewBuilder content: () -> Content) {
        self.viewModel = viewModel
        self.content = content()
    }

    var body: some View {
        AudioControlRootView(
            viewModel: viewModel
        ) {
            content
        }
    }
}
