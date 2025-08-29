import SwiftUI
import MagicCore

struct LaunchViewSwitcher: View {
    @Binding var currentLaunchPageIndex: Int
    let plugins: [SuperPlugin]
    let onAppear: () -> Void
    
    var body: some View {
        // 收集所有插件的 LaunchView
        let pluginLaunchViews = plugins.compactMap { $0.addLaunchView() }
        
        // 使用 TabView 实现可滑动的 LaunchView 切换
        TabView(selection: $currentLaunchPageIndex) {
            // 首先显示所有插件提供的 LaunchView
            ForEach(Array(pluginLaunchViews.enumerated()), id: \.offset) { index, launchView in
                ZStack {
                    launchView
                    
                    // 为每个插件页面添加滑动提示（除了最后一个插件页面）
                    if index < pluginLaunchViews.count - 1 {
                        VStack {
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Text("滑动查看更多")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.7))
                                
                                Image(systemName: "arrow.right")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                            .padding(.bottom, 16)
                        }
                    }
                }
                .tag(index)
            }
            
            // 默认的 LaunchView 作为最后一个
            LaunchView()
                .tag(pluginLaunchViews.count)
                .onAppear {
                    // 只有当滑动到默认 LaunchView 时才执行 onAppear
                    if currentLaunchPageIndex == pluginLaunchViews.count {
                        onAppear()
                    }
                }
        }
        .ignoresSafeArea()
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .onChange(of: currentLaunchPageIndex) { _, newIndex in
            // 当滑动到默认 LaunchView 时执行 onAppear
            if newIndex == pluginLaunchViews.count {
                onAppear()
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
