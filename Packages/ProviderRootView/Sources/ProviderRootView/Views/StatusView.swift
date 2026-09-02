import CisumKernel
import SwiftUI

/// 底部状态区域。
struct StatusView: View {
    let kernel: CisumKernel

    private var isPlaying: Bool { kernel.playback?.isPlaying ?? false }
    private var pluginsReady: Bool { kernel.plugin != nil }

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(pluginsReady ? .green : .orange)
                .frame(width: 7, height: 7)
            Text(pluginsReady ? "插件系统就绪" : "初始化中")
                .foregroundStyle(.secondary)

            Spacer()

            Text(isPlaying ? "播放中" : "待机")
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
