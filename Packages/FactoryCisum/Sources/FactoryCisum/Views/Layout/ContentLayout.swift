import CisumKernel
import SwiftUI

/// 内容区域布局配置。
///
/// 为 ContentView 提供布局容器，后续可在这里加入详情面板显隐、动画和尺寸策略。
struct ContentLayout: View {
    let kernel: CisumKernel

    var body: some View {
        ContentView(kernel: kernel)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
