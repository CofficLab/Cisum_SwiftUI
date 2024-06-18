import SwiftUI

struct BtnTrash: View {
    @EnvironmentObject var audioManager: PlayManager
    @EnvironmentObject var appManager: AppManager

    var audio: Audio
    var dynamicSize = false

    var body: some View {
        ControlButton(
            title: "将「\(audio.title)」放入回收站",
            image: getImageName(),
            dynamicSize: dynamicSize,
            onTap: {
                Task {
                    await audioManager.db.trash(audio)
                    audioManager.next(manual: true)
                }
            })
    }

    private func getImageName() -> String {
        return "trash"
    }
}

#Preview("Layout") {
    LayoutView()
}
