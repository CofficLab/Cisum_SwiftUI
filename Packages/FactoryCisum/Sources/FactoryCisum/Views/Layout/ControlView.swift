import MagicPlayMan
import SwiftUI

/// 播放控制区域：封面、标题、状态、进度条和底部操作按钮。
///
/// 通过 `@EnvironmentObject` 读取内核注册的真实 `MagicPlayMan`。
struct ControlView: View {
    @EnvironmentObject private var man: MagicPlayMan

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                HeroView()
                    .frame(maxWidth: geometry.size.width > 900 ? 330 : .infinity)

                if geometry.size.width > 900 {
                    HeroView(compact: true)
                        .frame(maxWidth: 330)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }

                VStack(spacing: 0) {
                    TitleView()
                    StateView()
                        .frame(height: 38)

                    Spacer(minLength: 8)

                    PlayingProgressView()
                        .padding(.horizontal, 24)

                    ControlBtns()
                        .padding(.bottom, 18)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 18)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.background)
        }
    }
}
