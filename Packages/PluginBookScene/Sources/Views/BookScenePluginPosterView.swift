import CisumUIComponents
import ProviderScene
import SwiftUI

struct BookScenePluginPosterView: View {
    @Environment(\.posterDismissAction) private var dismissAction
    private let setCurrentScene: @MainActor (AppScene) -> Void

    init(setCurrentScene: @escaping @MainActor (AppScene) -> Void) {
        self.setCurrentScene = setCurrentScene
    }

    var body: some View {
        BookPosterView(
            enterScene: {
                setCurrentScene(.audiobooks)
            },
            dismissPoster: {
                dismissAction()
            }
        )
    }
}
