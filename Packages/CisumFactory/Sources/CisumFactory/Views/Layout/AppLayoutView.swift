import CisumKernel
import SwiftUI

/// 根布局。
public struct AppLayoutView: View {
    @ObservedObject private var kernel: CisumKernel
    @State private var isDetailVisible = true

    public init(kernel: CisumKernel) {
        self.kernel = kernel
    }

    public var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ControlView()
                    .frame(height: isDetailVisible ? min(420, max(320, geometry.size.height * 0.48)) : nil)

                if isDetailVisible {
                    ContentLayout(kernel: kernel)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                StatusView(kernel: kernel)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .background(.background)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                SceneSwitcher(kernel: kernel)
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        isDetailVisible.toggle()
                    }
                } label: {
                    Label(
                        isDetailVisible ? "隐藏内容" : "显示内容",
                        systemImage: "rectangle.bottomhalf.inset.filled"
                    )
                }
            }
        }
    }
}
