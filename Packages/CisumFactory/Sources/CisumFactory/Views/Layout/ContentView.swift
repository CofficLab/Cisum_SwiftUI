import CisumKernel
import SwiftUI

/// 内容区域根视图。
///
/// 旧版 ContentView 负责承载 AppTabView；新版保持同样的职责，
/// 将插件内容与 Mock 内容统一交给 AppTabView 构建。
struct ContentView: View {
    let kernel: CisumKernel
    @ObservedObject var model: MockPlayerModel

    var body: some View {
        AppTabView(kernel: kernel, model: model)
    }
}
