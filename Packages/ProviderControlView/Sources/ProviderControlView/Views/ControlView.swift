import MagicPlayMan
import SwiftUI

/// 播放控制区域：封面、标题、状态、进度条和底部操作按钮。
///
/// 通过 `@EnvironmentObject` 读取内核注册的真实 `MagicPlayMan`。
struct ControlView: View {
    @EnvironmentObject private var man: MagicPlayMan
    let stateViews: @MainActor () -> [AnyView]
    let stateMessage: @MainActor () -> String
    let toggleDBView: @MainActor () -> Void

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    HeroView(rightAlbumVisible: shouldShowRightAlbum(geometry))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    StateView(stateViews: stateViews, stateMessage: stateMessage)
                        .frame(height: stateHeight(for: geometry))
                        .frame(maxWidth: .infinity)

                    man.makeProgressView()
                        .padding()

                    ControlBtns(toggleDBView: toggleDBView)
                        .frame(height: buttonHeight(for: geometry))
                        .frame(maxWidth: .infinity)
                }

                if shouldShowRightAlbum(geometry) {
                    HStack {
                        Spacer(minLength: 0)
                        man.makeHeroView()
                    }
                    .frame(maxWidth: geometry.size.height * 1.3)
                }
            }
            .padding(.bottom, 0)
            .padding(.horizontal, 0)
            .frame(maxHeight: .infinity)
        }
        .ignoresSafeArea(edges: .horizontal)
        .frame(minHeight: 250)
    }

    private func stateHeight(for geometry: GeometryProxy) -> CGFloat {
        if geometry.size.height <= 250 { return 24 }
        if geometry.size.height <= 450 { return 36 }
        return 48
    }

    private func buttonHeight(for geometry: GeometryProxy) -> CGFloat {
        min(geometry.size.width / 5, 900, geometry.size.height / 4)
    }

    private func shouldShowRightAlbum(_ geometry: GeometryProxy) -> Bool {
        geometry.size.width > 768
    }
}
