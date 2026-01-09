import MagicKit
import OSLog
import SwiftUI

struct LaunchViewSwitcher: View, SuperLog {
    nonisolated static let emoji = "🦭"

    @State var currentLaunchPageIndex: Int = 0

    let plugins: [SuperPlugin]
    let onEnd: () -> Void
    private let views: [AnyView]

    init(plugins: [SuperPlugin], onEnd: @escaping () -> Void) {
        self.plugins = plugins
        self.onEnd = onEnd
        self.views = plugins.compactMap { $0.addLaunchView() }
    }

    var body: some View {
        return GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        // 首先显示所有插件提供的 LaunchView
                        ForEach(Array(views.enumerated()), id: \.offset) { index, launchView in
                            ZStack {
                                launchView

                                // 为每个插件页面添加导航按钮
                                VStack {
                                    Spacer()

                                    // 统一的导航按钮
                                    HStack(spacing: 16) {
                                        // 上一页按钮
                                        if index > 0 {
                                            MagicButton.simple(icon: .iconPreviousPage) {
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    currentLaunchPageIndex = index - 1
                                                }
                                            }
                                            .magicStyle(.warning)
                                            .magicShape(.circle)
                                            .magicSize(.large)
                                            .magicShapeVisibility(.always)
                                        }

                                        // 下一页按钮
                                        MagicButton.simple(icon: .iconNextPage) {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                currentLaunchPageIndex = index + 1
                                            }
                                        }
                                        .magicStyle(.warning)
                                        .magicShape(.circle)
                                        .magicSize(.large)
                                        .magicShapeVisibility(.always)
                                    }
                                    .padding(.bottom, 16)
                                }
                            }
                            .frame(width: geometry.size.width)
                            .id(index)
                        }

                        // 默认的 LaunchView 作为最后一个
                        LaunchView()
                            .frame(width: geometry.size.width)
                            .id(views.count)
                    }
                }
                .onAppear {
                    if views.count == 0 {
                        self.runCallback()
                    }
                }
                .onChange(of: currentLaunchPageIndex) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(currentLaunchPageIndex, anchor: .center)
                    }

                    // 当切换到 LaunchView 时，执行回调
                    if currentLaunchPageIndex == views.count {
                        self.runCallback()
                    }
                }
                .ignoresSafeArea()
            }
        }
    }
}

// MARK: - Action

extension LaunchViewSwitcher {
    private func runCallback() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onEnd()
        }
    }
}

// MARK: - Event Handler

// MARK: - Preview

#if os(macOS)
    #Preview("App - Large") {
        AppPreview()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        AppPreview()
            .frame(width: 500, height: 800)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        AppPreview()
    }
#endif
