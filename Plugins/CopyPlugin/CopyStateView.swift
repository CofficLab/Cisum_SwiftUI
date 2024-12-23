import MagicKit
import OSLog
import SwiftData
import SwiftUI

struct CopyStateView: View, SuperLog, SuperThread {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var messageManager: MessageProvider
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \CopyTask.createdAt, animation: .default) var tasks: [CopyTask]

    var taskCount: Int { tasks.count }
    var showCopyMessage: Bool { tasks.count > 0 }
    static let emoji = "🖥️"
    let verbose = true

    var body: some View {
        if tasks.count > 0 && app.showDB == false {
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
            .background(BackgroundView.type3)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    func makeInfoView(_ i: String) -> some View {
        CardView(background: BackgroundView.type3, paddingVertical: 6) {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundStyle(.white)
                Text(i)
                    .foregroundStyle(.white)
            }
            .font(.title3)
        }
    }
}

#Preview("APP") {
    AppPreview()
        .frame(height: 800)
}
