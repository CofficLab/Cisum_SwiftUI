import SwiftData
import SwiftUI

struct StateCopy: View {
    @EnvironmentObject var dataManager: DataProvider

    @Query(sort: \CopyTask.createdAt, animation: .default) var tasks: [CopyTask]

    var background: some View = BackgroundView.type3

    var body: some View {
        HStack {
            Image(systemName: "info.circle")
                .foregroundStyle(.white)
            Text("正在复制 \(tasks.count) 个文件")
                .foregroundStyle(.white)
            BtnToggleCopying()
                .labelStyle(.iconOnly)
        }
        .font(.callout)
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .task {
            dataManager.copyFiles()
        }
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
