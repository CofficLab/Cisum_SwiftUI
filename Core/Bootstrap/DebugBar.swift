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

// MARK: - Preview Tool Position

/// 预览工具位置
struct PreviewToolPosition: Codable {
    let x: Double
    let y: Double

    private static let userDefaultsKey = "previewToolPosition"

    /// 默认位置（右下角）
    static let `default` = PreviewToolPosition(x: -20, y: -20)

    /// 保存位置
    static func save(_ position: PreviewToolPosition) {
        if let data = try? JSONEncoder().encode(position) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }

    /// 加载位置
    static func load() -> PreviewToolPosition {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let position = try? JSONDecoder().decode(PreviewToolPosition.self, from: data) else {
            return `default`
        }
        // 验证位置是否合理，如果超出范围则重置
        if abs(position.x) > 600 || abs(position.y) > 600 {
            return `default`
        }
        return position
    }

    /// 重置位置到默认值
    static func reset() {
        save(`default`)
    }
}

// MARK: - Preview Size Selector

/// 预览尺寸选择器工具栏（可拖动）
struct PreviewSizeSelector: View {
    @State private var selectedPreset: PreviewSize
    @State private var offset: CGSize
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false

    let containerSize: CGSize  // 容器大小
    let onShowTip: () -> Void

    init(containerSize: CGSize, onShowTip: @escaping () -> Void) {
        _selectedPreset = State(initialValue: PreviewSize.load())
        _offset = State(initialValue: CGSize(
            width: PreviewToolPosition.load().x,
            height: PreviewToolPosition.load().y
        ))
        self.containerSize = containerSize
        self.onShowTip = onShowTip
    }

    var body: some View {
        VStack(spacing: 8) {
            // 拖动手柄（双击重置位置）
            HStack {
                Spacer()
                Circle()
                    .fill(.secondary.opacity(0.5))
                    .frame(width: 4, height: 4)
                Circle()
                    .fill(.secondary.opacity(0.5))
                    .frame(width: 4, height: 4)
                Circle()
                    .fill(.secondary.opacity(0.5))
                    .frame(width: 4, height: 4)
                Spacer()
            }
            .onTapGesture(count: 2) {
                // 双击重置位置
                withAnimation {
                    offset = CGSize(width: PreviewToolPosition.default.x, height: PreviewToolPosition.default.y)
                    dragOffset = .zero
                }
                PreviewToolPosition.reset()
            }

            Divider()
                .background(.secondary.opacity(0.3))

            // 尺寸按钮
            ForEach(PreviewSize.allCases) { preset in
                presetButton(preset)
            }
        }
        .padding(12)
        .background(LinearGradient.spring.opacity(0.9))
        .roundedMedium()
        .shadow3xl()
        .frame(maxWidth: 200)
        .offset(x: offset.width + dragOffset.width, y: offset.height + dragOffset.height)
        .simultaneousGesture(
            DragGesture()
                .onChanged { value in
                    isDragging = true
                    // 实时更新拖动偏移（跟手）
                    dragOffset = value.translation

                    // 计算最终位置
                    let finalX = offset.width + value.translation.width
                    let finalY = offset.height + value.translation.height

                    // 动态计算边界：基于容器大小
                    // 工具栏大约 200 宽，高度动态，至少保留 80pt 可见
                    let toolBarWidth: CGFloat = 200
                    let toolBarHeight: CGFloat = 250  // 估算高度
                    let minVisible: CGFloat = 80  // 至少保留 80pt 可见

                    let maxX = containerSize.width / 2 - toolBarWidth / 2 + 100
                    let minX = -(containerSize.width / 2 + toolBarWidth / 2) + minVisible
                    let maxY = containerSize.height / 2 - toolBarHeight / 2 + 100
                    let minY = -(containerSize.height / 2 + toolBarHeight / 2) + minVisible

                    let clampedX = min(max(finalX, minX), maxX)
                    let clampedY = min(max(finalY, minY), maxY)

                    // 如果超出边界，视觉上继续显示但限制在边界内
                    if finalX != clampedX || finalY != clampedY {
                        dragOffset = CGSize(
                            width: clampedX - offset.width,
                            height: clampedY - offset.height
                        )
                    }
                }
                .onEnded { _ in
                    isDragging = false
                    // 保存最终位置
                    let finalX = offset.width + dragOffset.width
                    let finalY = offset.height + dragOffset.height

                    withAnimation(.interactiveSpring()) {
                        offset = CGSize(width: finalX, height: finalY)
                        dragOffset = .zero
                    }

                    PreviewToolPosition.save(
                        PreviewToolPosition(x: finalX, y: finalY)
                    )
                }
        )
        #if os(macOS)
        .draggableCursor()
        .onChange(of: isDragging) { _, newValue in
            if newValue {
                NSCursor.closedHand.push()
            } else {
                NSCursor.pop()
            }
        }
        #endif
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
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(selectedPreset == preset ? Color.accentColor : Color.clear)
                .cornerRadius(4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - View Extension for Preview Mode

extension View {
    /// 设置预览模式（自动应用保存的尺寸和工具位置）
    /// - Returns: 启用预览模式的视图，显示可拖动的尺寸选择器
    func withDebugBar() -> some View {
        let size = PreviewSize.load().size
        return DynamicPreviewSizingView(content: self, size: size)
    }
}

// MARK: - Dynamic Preview Sizing View

/// 预览尺寸容器视图
@MainActor
private struct DynamicPreviewSizingView<Content: View>: View {
    let content: Content
    let size: CGSize

    @State private var showTip = false

    init(content: Content, size: CGSize) {
        self.content = content
        self.size = size
    }

    var body: some View {
        #if os(macOS)
        ZStack {
            content
                .frame(width: size.width, height: size.height)
                .overlay(alignment: .bottomTrailing) {
                    PreviewSizeSelector(containerSize: size) {
                        showTip = true
                    }
                    .padding(20)
                }

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
        #else
        // iOS 平台直接返回原内容
        content
        #endif
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

// MARK: - Cursor Extension

#if os(macOS)
extension View {
    /// 设置拖动手柄的鼠标指针
    func draggableCursor() -> some View {
        self.onHover { isHovering in
            if isHovering {
                NSCursor.openHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}
#endif

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
