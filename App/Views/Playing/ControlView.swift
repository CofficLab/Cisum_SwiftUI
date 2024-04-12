import SwiftUI

struct ControlView: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                VStack {
                    VStack {
                        if shouldShowTopAlbum(geo) {
                            PlayingAlbum()
                        }
                        Spacer()
                        TitleView().padding()
                        ErrorView()
                    }
                    //.background(.red.opacity(0.1))
                    
//                    Spacer(minLength: 0)

                    VStack {
//                        Spacer(minLength: 0)
                        SliderView().padding()
                        BtnsView().padding()
                    }
                    // StateView()
                }
                //.background(.red.opacity(0.1))

                // MARK: 横向的封面图
                
                if shouldShowRightAlbum(geo) {
                    // 最大宽度=控制栏的高度+系统标题栏高度
                    HStack {
                        Spacer()
                        PlayingAlbum()
                    }.frame(maxWidth: geo.size.height * 1.3)
                }
            }
            .padding(.bottom, 0)
            .padding(.horizontal, 0)
            .frame(maxHeight: .infinity)
        }
        .foregroundStyle(.white)
        .ignoresSafeArea()
        .frame(minHeight: AppConfig.controlViewMinHeight)
    }
    
    private func shouldShowRightAlbum(_ geo: GeometryProxy) -> Bool {
        geo.size.width > 500
    }
    
    private func shouldShowTopAlbum(_ geo: GeometryProxy) -> Bool {
        !shouldShowRightAlbum(geo) && geo.size.height > 500
    }
}

#Preview("1") {
    LayoutPreview(width: AppConfig.minWidth, height: AppConfig.minHeight)
}

#Preview("2") {
    LayoutPreview(width: AppConfig.minWidth + 100, height: AppConfig.minHeight)
}

#Preview("3") {
    LayoutPreview(width: AppConfig.minWidth+200, height: AppConfig.minHeight)
}

#Preview("4") {
    LayoutPreview(width: AppConfig.minWidth+300, height: AppConfig.minHeight)
}
