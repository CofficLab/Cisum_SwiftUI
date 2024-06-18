import OSLog
import SwiftUI

struct RowTask: View {
    @EnvironmentObject var audioManager: PlayManager

    @State var hovered = false

    var task: CopyTask
    var background: Color {
        hovered ? AppConfig.getBackground.opacity(0.9) : .clear
    }

    init(_ task: CopyTask) {
        self.task = task
    }

    var body: some View {
        ZStack {
            HStack {
                Text(task.title)
                Spacer()
            }
            .frame(height: 32)

            if hovered {
                HStack {
                    Spacer()
                    BtnShowInFinder(url: task.url, autoResize: false)
                        .labelStyle(.iconOnly)
                    BtnDelTask(tasks: [task.id])
                        .labelStyle(.iconOnly)
                }
            }
        }
        .onHover(perform: { hovered = $0 })
        .frame(maxHeight: .infinity)
        .contextMenu(menuItems: {
            if AppConfig.isDesktop {
                BtnShowInFinder(url: task.url, autoResize: false)
            }
            Divider()
            BtnDelTask(tasks: [task.id], autoResize: false)
        })
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer)
}
