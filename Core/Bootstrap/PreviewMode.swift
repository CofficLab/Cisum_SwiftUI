import MagicKit
import SwiftUI

// MARK: - Preview Size Presets

/// 预览尺寸预设
struct PreviewSize: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let size: CGSize

    /// 从尺寸字符串创建预设（如 "500 × 800"）
    init(_ name: String) {
        self.name = name
        let components = name.split(separator: "×").map { $0.trimmingCharacters(in: .whitespaces) }
        guard components.count == 2,
              let width = Double(components[0]),
              let height = Double(components[1]) else {
            self.size = CGSize(width: 600, height: 900) // 默认尺寸
            return
        }
        self.size = CGSize(width: width, height: height)
    }

    /// 直接指定宽高
    init(width: Double, height: Double) {
        self.name = "\(Int(width)) × \(Int(height))"
        self.size = CGSize(width: width, height: height)
    }

    /// Equatable 实现（仅比较尺寸）
    static func == (lhs: PreviewSize, rhs: PreviewSize) -> Bool {
        lhs.size == rhs.size
    }
}

// MARK: - Available Presets

extension PreviewSize {
    /// 所有可用的预设尺寸
    /// 在这里添加或删除尺寸即可，修改后需重新打开预览生效
    static let allCases: [PreviewSize] = [
        PreviewSize("500 × 700"),
        PreviewSize("500 × 800"),
        PreviewSize("500 × 1000"),
        PreviewSize("600 × 900"),
        PreviewSize("800 × 1000"),
        PreviewSize("1000 × 1200"),
    ]

    /// 默认尺寸
    static let `default` = PreviewSize("600 × 900")
}

// MARK: - Preview Size Storage

extension PreviewSize {
    private static let userDefaultsKey = "previewSizePreset"

    /// 保存用户选择的预设尺寸
    static func save(_ preset: PreviewSize) {
        UserDefaults.standard.set(preset.name, forKey: userDefaultsKey)
    }

    /// 加载用户选择的预设尺寸
    static func load() -> PreviewSize {
        let savedName = UserDefaults.standard.string(forKey: userDefaultsKey)
        return allCases.first { $0.name == savedName } ?? `default`
    }
}

// MARK: - Preview Size Selector

/// 预览尺寸选择器工具栏
struct PreviewSizeSelector: View {
    @State private var selectedPreset: PreviewSize
    let vertical: Bool
    let onShowTip: () -> Void

    init(vertical: Bool = false, onShowTip: @escaping () -> Void) {
        _selectedPreset = State(initialValue: PreviewSize.load())
        self.vertical = vertical
        self.onShowTip = onShowTip
    }

    var body: some View {
        Group {
            if vertical {
                VStack(spacing: 8) {
                    ForEach(PreviewSize.allCases) { preset in
                        presetButton(preset)
                    }
                }
            } else {
                HStack(spacing: 8) {
                    ForEach(PreviewSize.allCases) { preset in
                        presetButton(preset)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func presetButton(_ preset: PreviewSize) -> some View {
        Button(action: {
            selectedPreset = preset
            PreviewSize.save(preset)
            onShowTip()
        }) {
            Text(preset.name)
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
    /// - Parameter vertical: 是否使用垂直布局排列尺寸选择器，默认为 true（垂直布局）
    /// - Returns: 启用预览模式的视图，会在右下角显示尺寸选择器
    func inPreviewMode(vertical: Bool = true) -> some View {
        let size = PreviewSize.load().size
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

    @State private var showTip = false

    init(content: Content, size: CGSize, vertical: Bool = false) {
        self.content = content
        self.size = size
        self.vertical = vertical
    }

    var body: some View {
        ZStack {
            content
                #if os(macOS)
                .frame(width: size.width, height: size.height)
                .overlay(alignment: .bottomTrailing) {
                    PreviewSizeSelector(vertical: vertical) {
                        showTip = true
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 6)
                    .padding(.bottom, 6)
                    .background(LinearGradient.spring.opacity(0.8))
                    .roundedCustom(topLeading: 12, bottomLeading: 12)
                    .shadow3xl()
                    .padding(.bottom, 48)
                }
                #endif

            // 提示在整个预览窗口中心显示
            if showTip {
                TipView()
                    .transition(.scale.combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showTip = false
                            }
                        }
                    }
            }
        }
    }
}

// MARK: - Tip View

/// 尺寸变更提示视图
private struct TipView: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
            VStack(alignment: .leading, spacing: 4) {
                Text("尺寸已更改")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("重新打开预览即可生效")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .foregroundStyle(.white)
        .padding(16)
        .background(.ultraThinMaterial)
        .background(Color.blue.opacity(0.9))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 4)
        .padding(.horizontal, 40)
    }
}

// MARK: Preview

#Preview("App - Vertical") {
    ContentView()
        .inRootView()
        .inPreviewMode()  // 默认垂直布局
}

#Preview("App - Horizontal") {
    ContentView()
        .inRootView()
        .inPreviewMode(vertical: false)  // 横向布局
}
