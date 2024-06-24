import SwiftUI
import SwiftData

struct CopyState: View {
    @EnvironmentObject var db: DB
    
    @Query(sort: \CopyTask.createdAt, animation: .default) var tasks: [CopyTask]
    
    var withBackground: Bool
    var background: some View = BackgroundView.type3
    
    init(withBackground: Bool = false) {
        self.withBackground = withBackground
    }
    
    var body: some View {
        HStack {
            Image(systemName: "info.circle")
                .foregroundStyle(.white)
            Text("正在复制 \(tasks.count) 个文件")
                .foregroundStyle(withBackground ? .white : .secondary)
            BtnToggleCopying()
                .labelStyle(.iconOnly)
        }
        .font(.callout)
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(background.opacity(withBackground ? 1 : 0))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .task {
            try? await db.copyFiles()
        }
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
