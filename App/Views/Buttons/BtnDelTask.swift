import SwiftUI

struct BtnDelTask: View {
    @EnvironmentObject var audioManager: PlayManager
    @State var hovered = false
    @Environment(\.modelContext) private var modelContext

    var tasks: Set<CopyTask.ID>
    var autoResize = false

    var body: some View {
        ControlButton(
            title: "删除 \(tasks.count) 个",
            image: getImageName(),
            dynamicSize: autoResize,
            onTap: {
                for task in tasks {
                    Task {
                        await audioManager.db.deleteCopyTask(task)
                    }
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
