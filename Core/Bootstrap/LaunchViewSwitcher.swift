import MagicCore
import SwiftUI

struct LaunchViewSwitcher: View {
    @Binding var currentLaunchPageIndex: Int
    let plugins: [SuperPlugin]
    let onAppear: () -> Void
    
    @State private var hasTriggeredOnAppear = false
    
    var body: some View {
        let pluginLaunchViews = plugins.compactMap { $0.addLaunchView() }
        
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        // 首先显示所有插件提供的 LaunchView
                        ForEach(Array(pluginLaunchViews.enumerated()), id: \.offset) { index, launchView in
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
                            .onAppear {
                                // 当插件页面出现时，延迟执行 onAppear 回调
                                // 这样新设备在显示欢迎页面时也能正常进入应用
                                if !hasTriggeredOnAppear {
                                    hasTriggeredOnAppear = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        onAppear()
                                    }
                                }
                            }
                        }
                        
                        // 默认的 LaunchView 作为最后一个
                        LaunchView()
                            .frame(width: geometry.size.width)
                            .id(pluginLaunchViews.count)
                            .onAppear {
                                // 当没有插件视图时（pluginLaunchViews.count == 0），
                                // 并且当前索引为0时，直接执行 onAppear 回调
                                if pluginLaunchViews.count == 0 && currentLaunchPageIndex == 0 && !hasTriggeredOnAppear {
                                    hasTriggeredOnAppear = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        onAppear()
                                    }
                                }
                            }
                    }
                }
                .onChange(of: currentLaunchPageIndex) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(currentLaunchPageIndex, anchor: .center)
                    }
                    
                    // 当切换到 LaunchView 时，延迟执行 onAppear 回调
                    if currentLaunchPageIndex == pluginLaunchViews.count && !hasTriggeredOnAppear {
                        hasTriggeredOnAppear = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            onAppear()
                        }
                    }
                }
                .ignoresSafeArea()
            }
        }
    }
}

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
