import MagicCore
import SwiftUI

struct LaunchViewSwitcher: View {
    @Binding var currentLaunchPageIndex: Int
    let plugins: [SuperPlugin]
    let onAppear: () -> Void

    var body: some View {
        let pluginLaunchViews = plugins.compactMap { $0.addLaunchView() }

        // 使用 TabView 实现可滑动的 LaunchView 切换
        TabView(selection: $currentLaunchPageIndex) {
            // 首先显示所有插件提供的 LaunchView
            ForEach(Array(pluginLaunchViews.enumerated()), id: \.offset) { index, launchView in
                ZStack {
                    launchView

                    // 为每个插件页面添加滑动提示和导航按钮
                    VStack {
                        Spacer()

                        #if os(iOS)
                        HStack(spacing: 8) {
                            Text("滑动查看更多")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))

                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .padding(.bottom, 16)
                        #endif
                        
                        // macOS 专用导航按钮
                        #if os(macOS)
                        HStack(spacing: 16) {
                            // 上一页按钮
                            if index > 0 {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentLaunchPageIndex = index - 1
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "chevron.left")
                                        Text("上一页")
                                    }
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.8))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(.white.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(.plain)
                            }
                            
                            // 下一页按钮
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentLaunchPageIndex = index + 1
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Text("下一页")
                                    Image(systemName: "chevron.right")
                                }
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.white.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.bottom, 16)
                        #endif
                    }
                }
                .tag(index)
            }

            // 默认的 LaunchView 作为最后一个
            LaunchView()
                .tag(pluginLaunchViews.count)
                .onAppear() {
                    // 延迟1秒执行onAppear回调
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        onAppear()
                    }
                }
        }
        #if os(iOS)
        .ignoresSafeArea()
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        #endif
        
        #if os(macOS)
        .tabViewStyle(.tabBarOnly)
        #endif
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
