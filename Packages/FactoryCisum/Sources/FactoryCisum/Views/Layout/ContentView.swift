import CisumKernel
import SwiftUI

/// 内容区域根视图。
///
/// 将插件内容统一交给 `AppTabView` 构建。
struct ContentView: View {
    let kernel: CisumKernel

    var body: some View {
        AppTabView(kernel: kernel)
    }
}
