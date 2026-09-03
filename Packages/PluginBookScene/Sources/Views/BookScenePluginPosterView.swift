import CisumUIComponents
import SwiftUI

struct BookScenePluginPosterView: View {
    @Environment(\.posterDismissAction) private var dismissAction
    private let setCurrentScene: @MainActor (String) throws -> Void

    init(setCurrentScene: @escaping @MainActor (String) throws -> Void) {
        self.setCurrentScene = setCurrentScene
    }

    var body: some View {
        BookPosterView(
            enterScene: {
                try setCurrentScene(BookScenePlugin.sceneName)
            },
            dismissPoster: {
                dismissAction()
            }
        )
    }
}
