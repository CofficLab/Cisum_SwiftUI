import SwiftUI

#if os(macOS) || os(iOS)
public struct MagicMenu: View {
    public var title: String = "[无标题]"
    public var dragging: Bool = false
    public var trailing: String = ""
    public var isFolder: Bool = false
    public var level: Int = 0
    public var loading: Bool = false

    @Binding public var deleting: Bool
    @Binding public var selected: Bool
    @Binding public var collapsed: Bool
    @Binding public var forceIcon: String
    public var clicked: () -> Void = {}

    @State private var indicatorHovered: Bool = false
    @State private var hovered: Bool = false
    
    public init(
        title: String, 
        dragging: Bool = false, 
        trailing: String = "", 
        isFolder: Bool = false, 
        level: Int = 0, 
        forceIcon: Binding<String> = Binding.constant(""),
        loading: Bool = false,
        deleting: Binding<Bool> = Binding.constant(false),
        selected: Binding<Bool> = Binding.constant(false),
        collapsed: Binding<Bool> = Binding.constant(false),
        clicked: @escaping () -> Void = {},
        indicatorHovered: Bool = false, 
        hovered: Bool = false
    ) {
        self.title = title
        self.dragging = dragging
        self.trailing = trailing
        self.isFolder = isFolder
        self.level = level
        self.loading = loading
        self.clicked = clicked
        self.indicatorHovered = indicatorHovered
        self.hovered = hovered
        self._deleting = deleting
        self._selected = selected
        self._collapsed = collapsed
        self._forceIcon = forceIcon
    }

    private var icon: some View {
        #if os(macOS)
            var color = Color(.controlAccentColor)
        #endif

        #if os(iOS)
            var color = Color(.blue)
        #endif

        if selected == true {
            color = Color(.white)
        }

        var systemName = isFolder ? "folder" : "doc.text"
        if !forceIcon.isEmpty {
            systemName = forceIcon
        }
        return HStack {
            Image(systemName: systemName)
                .resizable()
                .frame(width: isFolder ? 14 : 12, height: isFolder ? 12 : 15)
                .foregroundColor(color)
                .padding(.trailing, isFolder ? 0 : 2)
        }
    }

    // MARK: 计算背景色

    private var background: some View {
        if dragging {
            return Color.white.opacity(0.5)
        }

        if selected {
            #if os(macOS)
                return Color(.controlAccentColor).opacity(0.8)
            #endif

            #if os(iOS)
                return Color(.blue).opacity(0.8)
            #endif
        }

        if deleting == true {
            return Color(.gray).opacity(0.4)
        }

        #if os(macOS)
            if hovered {
                return Color(.controlAccentColor).opacity(0.1)
            }
        #endif

        return Color.clear
    }

    private var foregroundColor: Color {
        selected == true ? Color.white : Color.primary
    }

    public var body: some View {
        ZStack {
            background

            HStack(spacing: 2) {
                Image(systemName: collapsed ? "chevron.forward" : "chevron.down")
                    .frame(width: 4, height: 4)
                    .foregroundColor(foregroundColor)
                    .onTapGesture { collapsed.toggle() }
                    .opacity(isFolder ? 1 : 0)
                    .onHover { hovering in
                        indicatorHovered = hovering
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .cornerRadius(4)
                    .background(getIndicatorBackground())
                    .accessibilityIdentifier("indicator")

                icon
                    .accessibilityIdentifier("icon")

                Text(title)
                    .foregroundColor(foregroundColor)
                    .accessibilityIdentifier("title")

                Spacer()
                    .accessibilityIdentifier("spacer")

                Text(trailing)
                    .font(.footnote)
                    .foregroundColor(foregroundColor)
                    .opacity(isFolder ? 1 : 0)
                    .accessibilityIdentifier("trailing")

                if deleting || loading {
                    ProgressView()
                    .controlSize(.small)
                        .accessibilityIdentifier("progress")
                }
            }
            .onHover(perform: { v in
                hovered = v
            })
            .padding(.vertical, 4)
            .padding(.trailing, 12)
            .padding(.leading, 4 * CGFloat(level))
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .onTapGesture(count: 2) {
            collapsed.toggle()
            clicked()
        }

        // MARK: 单击事件

        .onTapGesture(count: 1) {
            clicked()
        }
        .cornerRadius(4)
        #if os(macOS)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(hovered ? Color(.controlAccentColor).opacity(0) : Color.clear, lineWidth: 1)
            )
        #endif
    }

    private func getIndicatorBackground() -> some ShapeStyle {
        if selected && indicatorHovered {
            return Color.gray.opacity(0.7)
        }

        if indicatorHovered {
            return Color.gray.opacity(0.2)
        }

        return Color.clear
    }
}

#if DEBUG
struct MenuTile_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            MagicMenu(
                title: "普通",
                dragging: false,
                trailing: "",
                isFolder: false,
                deleting: Binding.constant(false),
                selected: Binding.constant(false),
                collapsed: Binding.constant(false)
            )
            MagicMenu(
                title: "普通删除中",
                dragging: false,
                deleting: Binding.constant(true),
                selected: Binding.constant(false),
                collapsed: Binding.constant(true)
            )
            MagicMenu(
                title: "普通加载中",
                dragging: false,
                loading: true,
                deleting: Binding.constant(false),
                selected: Binding.constant(false),
                collapsed: Binding.constant(true)
            )
            MagicMenu(
                title: "普通目录",
                dragging: false,
                isFolder: true,
                deleting: Binding.constant(false),
                selected: Binding.constant(false),
                collapsed: Binding.constant(true)
            )
            MagicMenu(
                title: "选中目录",
                dragging: false,
                isFolder: true,
                deleting: Binding.constant(false),
                selected: Binding.constant(false),
                collapsed: Binding.constant(false)
            )
            MagicMenu(
                title: "普通带尾部",
                dragging: false,
                trailing: "9",
                deleting: Binding.constant(false),
                selected: Binding.constant(false),
                collapsed: Binding.constant(false)
            )
            MagicMenu(
                title: "选中",
                dragging: false,
                deleting: Binding.constant(false),
                selected: Binding.constant(false),
                collapsed: Binding.constant(false)
            )
            MagicMenu(
                title: "展开",
                dragging: false,
                deleting: Binding.constant(false),
                selected: Binding.constant(false),
                collapsed: Binding.constant(false)
            )
            MagicMenu(
                title: "选中带尾部",
                dragging: false,
                trailing: "89",
                deleting: Binding.constant(false),
                selected: Binding.constant(false),
                collapsed: Binding.constant(false)
            )
            MagicMenu(
                title: "普通",
                dragging: false,
                trailing: "",
                isFolder: false,
                deleting: Binding.constant(false),
                selected: Binding.constant(false),
                collapsed: Binding.constant(false)
            )
            MagicMenu(
                title: "选中展开",
                dragging: false,
                deleting: Binding.constant(false),
                selected: Binding.constant(false),
                collapsed: Binding.constant(false)
            )
        }
        .frame(width: 300)
        .padding(.all, 8)
    }
}
#endif
#endif
