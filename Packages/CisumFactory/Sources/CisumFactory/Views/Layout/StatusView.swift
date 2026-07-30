import CisumKernel
import SwiftUI

/// 底部状态区域，对应旧版 StatusView。
struct StatusView: View {
    let kernel: CisumKernel
    @ObservedObject var model: MockPlayerModel

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(.green)
                .frame(width: 7, height: 7)
            Text(kernel.plugin == nil ? "Mock 模式" : "插件系统就绪")
                .foregroundStyle(.secondary)

            Spacer()

            Text(model.isPlaying ? "播放中" : "待机")
                .foregroundStyle(.secondary)
            Text("•")
                .foregroundStyle(.tertiary)
            Text("Cisum")
                .foregroundStyle(.tertiary)
        }
        .font(.caption)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.background)
    }
}
