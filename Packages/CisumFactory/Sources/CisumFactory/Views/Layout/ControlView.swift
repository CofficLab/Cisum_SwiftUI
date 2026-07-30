import SwiftUI

/// 播放控制区域。
///
/// 对应旧版 ControlView：封面、标题、状态、进度条和底部操作按钮。
struct ControlView: View {
    @ObservedObject var model: MockPlayerModel

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                HeroView(model: model)
                    .frame(maxWidth: geometry.size.width > 900 ? 330 : .infinity)

                if geometry.size.width > 900 {
                    HeroView(model: model, compact: true)
                        .frame(maxWidth: 330)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }

                VStack(spacing: 0) {
                    TitleView(model: model)
                    StateView(model: model)
                        .frame(height: 38)

                    Spacer(minLength: 8)

                    PlayingProgressView(model: model)
                        .padding(.horizontal, 24)

                    ControlBtns(model: model)
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
