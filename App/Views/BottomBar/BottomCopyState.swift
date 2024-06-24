import SwiftUI
import SwiftData

struct BottomCopyState: View {
    @EnvironmentObject var db: DB
    @EnvironmentObject var app: AppManager
    
    @Query(sort: \CopyTask.createdAt, animation: .default) var tasks: [CopyTask]
    
    var withBackground: Bool
    var background: some View = BackgroundView.type3
    
    init(withBackground: Bool = false) {
        self.withBackground = withBackground
    }
    
    var body: some View {
        if tasks.count > 0 {
            BottomTile(
                title: "正在复制 \(tasks.count) 个文件",
                image: "info.circle",
                onTap: {
                    app.showCopying.toggle()
                }
            )
            .labelStyle(.titleAndIcon)
            .task {
                try? await db.copyFiles()
            }
        }
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}