import MagicKit
import OSLog
import SwiftUI

struct Launcher: View, SuperLog {
    nonisolated static let emoji = "🦭"
    nonisolated static let verbose = true

    @State var currentLaunchPageIndex: Int = 0

    let plugins: [SuperPlugin]
    private let views: [AnyView]

    init(plugins: [SuperPlugin]) {
        let views = plugins.compactMap { $0.addLaunchView() }
        self.plugins = plugins
        self.views = views
        if Self.verbose {
            os_log("\(Self.t)✅ 初始化完成, LaunchView 数量: \(views.count)")
        }
    }

    var body: some View {
        GeometryReader { geometry in
            Group {
                if views.count > 0 {
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                // 首先显示所有插件提供的 LaunchView
                                pluginViewsWithNavigation(geometry: geometry)

                                // 默认的 LaunchView 作为最后一个
                                LaunchDoneView()
                                    .frame(width: geometry.size.width)
                                    .id(views.count)
                            }
                        }
                        .onChange(of: currentLaunchPageIndex) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo(currentLaunchPageIndex, anchor: .center)
                            }

                            if currentLaunchPageIndex == views.count {
                                emitLaunchDone()
                            }
                        }
                        .ignoresSafeArea()
                    }
                } else {
                    LaunchDoneView()
                        .onAppear(perform: emitLaunchDone)
                }
            }
        }
    }
}

// MARK: - Actions

extension Launcher {
    func emitLaunchDone() {
        NotificationCenter.default.post(name: .launchDone, object: nil)
    }
}

/// LaunchView 完成通知
extension Notification.Name {
    static let launchDone = Notification.Name("launchDone")
}

// MARK: - View Builder

extension Launcher {
    /// 生成带有导航按钮的插件视图
    /// - Parameter geometry: 几何信息，用于设置视图宽度
    /// - Returns: 包含导航按钮的插件视图数组
    private func pluginViewsWithNavigation(geometry: GeometryProxy) -> some View {
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
    }
}

/// SwiftUI View 扩展，提供 LaunchView 事件监听
extension View {
    /// 监听 LaunchView 显示事件
    /// - Parameter action: LaunchView 显示时执行的操作
    /// - Returns: 添加了监听器的视图
    func onLaunchDone(perform action: @escaping () -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .launchDone)) { _ in
            action()
        }
    }
}

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
