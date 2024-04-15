import SwiftUI

struct BtnDelTask: View {
    @State var hovered = false
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Button(action: {
            try? modelContext.delete(model: CopyTask.self)
        }, label: {
            Image(systemName: "trash")
        })
        .onHover(perform: { hovering in
            hovered = hovering
        })
        .labelStyle(.iconOnly)
        .buttonStyle(PlainButtonStyle())
        .popover(isPresented: $hovered, content: {
            Text("取消所有的任务").padding()
        })
    }
}

#Preview {
    BtnDelTask()
}

#Preview("Layout") {
    LayoutView()
}
