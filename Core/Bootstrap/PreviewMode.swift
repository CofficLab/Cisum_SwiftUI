import MagicKit
import SwiftUI

// MARK: - Preview Size Presets

/// 预览尺寸预设
enum PreviewSizePreset: String, CaseIterable {
    case small = "500 × 800"
    case medium = "600 × 900"
    case large = "800 × 1000"
    case xlarge = "1000 × 1200"

    var size: CGSize {
        switch self {
        case .small: return CGSize(width: 500, height: 800)
        case .medium: return CGSize(width: 600, height: 900)
        case .large: return CGSize(width: 800, height: 1000)
        case .xlarge: return CGSize(width: 1000, height: 1200)
        }
    }

    var displayName: String { rawValue }
}

// MARK: - Preview Size Storage

extension PreviewSizePreset {
    private static let userDefaultsKey = "previewSizePreset"

    /// 保存用户选择的预设尺寸
    static func save(_ preset: PreviewSizePreset) {
        UserDefaults.standard.set(preset.rawValue, forKey: userDefaultsKey)
    }

    /// 加载用户选择的预设尺寸
    static func load() -> PreviewSizePreset {
        let savedValue = UserDefaults.standard.string(forKey: userDefaultsKey)
        return savedValue.flatMap { PreviewSizePreset(rawValue: $0) } ?? .medium
    }
}

// MARK: - Preview Size Selector

/// 预览尺寸选择器工具栏
struct PreviewSizeSelector: View {
    @State private var selectedPreset: PreviewSizePreset
    @State private var showTip = false
    let vertical: Bool

    init(vertical: Bool = false) {
        _selectedPreset = State(initialValue: PreviewSizePreset.load())
        self.vertical = vertical
    }

    var body: some View {
        Group {
            if vertical {
                VStack(spacing: 8) {
                    ForEach(PreviewSizePreset.allCases, id: \.self) { preset in
                        presetButton(preset)
                    }
                }
            } else {
                HStack(spacing: 8) {
                    ForEach(PreviewSizePreset.allCases, id: \.self) { preset in
                        presetButton(preset)
                    }
                }
            }
        }
        .overlay(alignment: .top) {
            if showTip {
                TipView()
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    .offset(y: -36) // 往上移动，避免挡住按钮
                    .onAppear {
                        // 2秒后自动隐藏提示
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showTip = false
                            }
                        }
                    }
            }
        }
    }

    @ViewBuilder
    private func presetButton(_ preset: PreviewSizePreset) -> some View {
        Button(action: {
            selectedPreset = preset
            PreviewSizePreset.save(preset)
            // 显示提示
            withAnimation {
                showTip = true
            }
        }) {
            Text(preset.displayName)
                .font(.caption)
                .foregroundStyle(selectedPreset == preset ? .white : .secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(selectedPreset == preset ? Color.accentColor : Color.clear)
                .cornerRadius(4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - View Extension for Preview Mode

extension View {
    /// 设置预览模式（自动应用保存的尺寸）
    /// - Parameter vertical: 是否使用垂直布局排列尺寸选择器，默认为 false（横向布局）
    /// - Returns: 启用预览模式的视图，会在右下角显示尺寸选择器
    /// - Note: 在 Xcode 预览中使用此方法，可以避免加载真实数据或执行耗时操作
    /// - 首次使用时应用默认尺寸（600×900），使用过之后应用上次保存的尺寸
    /// - 更改尺寸需要重新打开预览才能生效
    ///
    /// 示例：
    /// ```swift
    /// #Preview("Products") {
    ///     ProductsSubscription()
    ///         .inRootView()
    ///         .inPreviewMode()  // 横向布局（默认）
    /// }
    ///
    /// #Preview("Products Vertical") {
    ///     ProductsSubscription()
    ///         .inRootView()
    ///         .inPreviewMode(vertical: true)  // 垂直布局
    /// }
    /// ```
    func inPreviewMode(vertical: Bool = false) -> some View {
        let size = PreviewSizePreset.load().size
        return DynamicPreviewSizingView(content: self, size: size, vertical: vertical)
    }
}

// MARK: - Dynamic Preview Sizing View

/// 预览尺寸容器视图
@MainActor
private struct DynamicPreviewSizingView<Content: View>: View {
    let content: Content
    let size: CGSize
    let vertical: Bool

    init(content: Content, size: CGSize, vertical: Bool = false) {
        self.content = content
        self.size = size
        self.vertical = vertical
    }

    var body: some View {
        content
        #if os(macOS)
        .frame(width: size.width, height: size.height)
        .overlay(alignment: .bottomTrailing) {
            PreviewSizeSelector(vertical: vertical)
                .padding(.horizontal, 12)
                .padding(.top, 6)
                .padding(.bottom, 6)
                .background(LinearGradient.spring.opacity(0.8))
                .roundedCustom(topLeading: 12, bottomLeading: 12)
                .shadow3xl()
                .padding(.bottom, 48)
        }
        #endif
    }
}

// MARK: - Tip View

/// 尺寸变更提示视图
private struct TipView: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "info.circle.fill")
                .font(.caption)
            Text("下次预览生效")
                .font(.caption)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.9))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        .padding(.bottom, 8)
    }
}

// MARK: Preview

#Preview("App - Horizontal") {
    ContentView()
        .inRootView()
        .inPreviewMode()  // 默认横向布局
}

#Preview("App - Vertical") {
    ContentView()
        .inRootView()
        .inPreviewMode(vertical: true)  // 垂直布局
}
