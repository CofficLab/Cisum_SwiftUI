import CisumUI
import SwiftUI

struct AudioDownloadPluginRootView<Content>: View where Content: View {
    @Environment(\.currentSceneName) private var currentSceneName
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        AudioDownloadRootView(currentSceneName: { currentSceneName }) {
            content
        }
    }
}
