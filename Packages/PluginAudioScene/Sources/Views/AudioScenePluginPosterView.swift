import CisumUIComponents
import SwiftUI

struct AudioScenePluginPosterView: View {
    @Environment(\.posterDismissAction) private var dismissAction
    private let setCurrentScene: @MainActor (String) throws -> Void

    init(setCurrentScene: @escaping @MainActor (String) throws -> Void) {
        self.setCurrentScene = setCurrentScene
    }

    var body: some View {
        AudioPosterView(
            enterScene: {
                try setCurrentScene(AudioScenePlugin.sceneName)
            },
            dismissPoster: {
                dismissAction()
            }
        )
    }
}
