import CisumUIComponents
import ProviderScene
import SwiftUI

struct AudioScenePluginPosterView: View {
    @Environment(\.posterDismissAction) private var dismissAction
    private let setCurrentScene: @MainActor (AppScene) -> Void

    init(setCurrentScene: @escaping @MainActor (AppScene) -> Void) {
        self.setCurrentScene = setCurrentScene
    }

    var body: some View {
        AudioPosterView(
            enterScene: {
                setCurrentScene(.music)
            },
            dismissPoster: {
                dismissAction()
            }
        )
    }
}
