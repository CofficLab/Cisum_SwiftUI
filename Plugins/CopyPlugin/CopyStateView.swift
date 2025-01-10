import MagicKit

import OSLog
import SwiftData
import SwiftUI

struct CopyStateView: View, @preconcurrency SuperLog, SuperThread {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var messageManager: MessageProvider
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \CopyTask.createdAt, animation: .default) var tasks: [CopyTask]

    @State private var showCopying = false

    var taskCount: Int { tasks.count }
    var showCopyMessage: Bool { tasks.count > 0 }
    static let emoji = "🖥️"
    let verbose = true

    var body: some View {
        if tasks.count > 0 {
            HStack {
                Image(systemName: "info.circle")
                Text("正在复制 \(tasks.count) 个文件")
                BtnToggleCopying(isActive: self.$showCopying)
                    .labelStyle(.iconOnly)
            }
            .font(.callout)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(MagicBackground.deepForest)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .popover(isPresented: $showCopying) {
                CopyList()
            }
        }
    }

    func makeInfoView(_ i: String) -> some View {
        MagicCard(background: MagicBackground.aurora, paddingVertical: 6) {
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

#Preview("APP") {
    RootView {
        CopyStateView()
    }
        .frame(height: 800)
}
