#if os(macOS)
import CisumUI
import MagicKit
import MagicAlert
import OSLog
import SwiftData
import SwiftUI

struct CopyStateView: View, SuperLog, SuperThread {
    @State private var showCopying = false
    @State private var taskCount: Int = 0

    nonisolated static let emoji = "🖥️"
    nonisolated static var verbose: Bool { false }

    /// 是否应该显示状态视图
    private var shouldShow: Bool {
        taskCount > 0
    }

    var body: some View {
        Group {
            if shouldShow {
                HStack {
                    Image(systemName: "info.circle")
                    Text("正在复制 \(taskCount) 个文件", tableName: "Audio-Copy-macOS", bundle: .module)
                    Image.cisumList.cisumButton {
                        self.showCopying.toggle()
                    }
                }
                .font(.callout)
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(CisumMagicBackground.deepForest)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .contentTransition(.numericText(value: Double(taskCount)))
                .popover(isPresented: $showCopying) {
                    CopyList()
                }
                .transition(.opacity.combined(with: .scale))
                .cisumShadowSm()
            }
        }
        .onCopyTaskCountChanged(perform: handleCopyTaskCountChanged)
        .onCopyTaskFinished(perform: handleCopyTaskFinished)
    }
}

// MARK: - View

extension CopyStateView {
    func makeInfoView(_ i: String) -> some View {
        HStack {
            Image(systemName: "info.circle")
                .foregroundStyle(.white)
            Text(i)
                .foregroundStyle(.white)
        }
        .cisumCard()
        .font(.title3)
    }
}

// MARK: - Event Handler

extension CopyStateView {
    func handleCopyTaskCountChanged(_ count: Int) {
        taskCount = count
    }

    func handleCopyTaskFinished(_ lastCount: Int) {
        // 任务完成，清零任务数量
        taskCount = 0
        alert_info(String(localized: "Copy completed", table: "Audio-Copy-macOS", bundle: .module))
    }
}
#endif
