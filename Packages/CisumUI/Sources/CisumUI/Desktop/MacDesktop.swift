import SwiftUI

/// 模拟 macOS 桌面视图，包含顶部任务栏和底部 Dock
struct MacDesktop<Content: View>: View {
    @State private var selectedApp: String? = nil
    @State private var isMenuBarExpanded = false
    private let content: Content

    // 任务栏应用
    private let menuBarApps = [
        ("apple.logo", "Apple"),
        ("safari", "Safari"),
        ("message", "Messages"),
        ("mail", "Mail"),
        ("calendar", "Calendar"),
        ("photos", "Photos"),
        ("music.note", "Music"),
        ("tv", "TV"),
        ("gamecontroller", "Game Center"),
        ("app.badge", "App Store"),
    ]

    // Dock 应用
    private let dockApps = [
        "Facetime",
        "Message",
        "Mail",
        "Map",
        "Note",
        "Safari",
    ]

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        GeometryReader { _ in
            ZStack {
                // 桌面背景
                MagicBackground.emerald

                // 桌面中心内容
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                // 顶部任务栏
                topMenuBar
                    .frame(height: 28)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                // 底部 Dock
                bottomDock
                    .frame(height: 80)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
        }
        .background(Color.black)
    }

    // MARK: - Top Menu Bar

    private var topMenuBar: some View {
        VStack {
            HStack {
                // 左侧 Apple Logo
                Button(action: { isMenuBarExpanded.toggle() }) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())

                // 应用菜单
                if isMenuBarExpanded {
                    HStack(spacing: 20) {
                        ForEach(menuBarApps, id: \.0) { app in
                            menuBarAppIcon(systemName: app.0, name: app.1)
                        }
                    }
                    .padding(.leading, 20)
                    .transition(.opacity.combined(with: .scale))
                }

                Spacer()

                // 右侧状态信息
                HStack(spacing: 16) {
                    statusItem(icon: "wifi")
                    statusItem(icon: "battery.100")
                    statusItem(icon: "", text: "10:30")
                }
            }
            .padding(.horizontal, 16)
            .background(
                Color.black.opacity(0.4)
                    .background(.ultraThinMaterial)
            )

            Spacer()
        }
    }

    // MARK: - Bottom Dock

    private var bottomDock: some View {
        VStack {
            Spacer()
            HStack(spacing: 8) {
                ForEach(dockApps, id: \.self) { app in
                    Image(app, bundle: Bundle.module)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
            )
            .padding(.bottom, 20)
            Spacer()
        }
    }

    // MARK: - Helper Views

    private func menuBarAppIcon(systemName: String, name: String) -> some View {
        Button(action: {}) {
            VStack(spacing: 2) {
                Image(systemName: systemName)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func statusItem(icon: String, text: String = "") -> some View {
        HStack(spacing: 4) {
            if icon != "" {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(.white)
            }
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.white)
        }
    }
}
