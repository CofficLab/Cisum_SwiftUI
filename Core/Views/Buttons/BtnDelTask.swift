import SwiftUI

struct BtnDelTask: View {
    @EnvironmentObject var db: AudioRecordDB
    
    @State var hovered = false

    var tasks: Set<CopyTask.ID>
    var autoResize = false

    var body: some View {
        ControlButton(
            title: "删除 \(tasks.count) 个",
            image: getImageName(),
            dynamicSize: autoResize,
            onTap: {
//                for task in tasks {
//                    Task {
//                        await db.deleteCopyTask(task)
//                    }
//                }
            })
    }

    private func getImageName() -> String {
        return "trash"
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Layout") {
    LayoutView()
}
