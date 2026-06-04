import CisumUI
import SwiftUI

struct BookScenePluginPosterView: View {
    @Environment(\.posterDismissAction) private var dismissAction
    @Environment(\.setCurrentSceneAction) private var setCurrentScene

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
