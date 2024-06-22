import SwiftUI

struct MenuTile<ID: Hashable>: View {
    var id: ID
    var title: String = "[无标题]"
    var dragging: Bool = false
    var trailing: String = ""
    var isFolder: Bool = false
    var level: Int = 0
    var loading: Bool = false

    @Binding var deleting: Bool
    @Binding var selectionId: ID?
    @Binding var collapsed: Bool
    @Binding var forceIcon: String
    var clicked: () -> Void = {}

    @State var indicatorHovered: Bool = false
    @State var hovered: Bool = false
    @State var lastClickedAt: Date = .distantPast
    
    var selected: Bool {
        id == selectionId
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
        if forceIcon.count > 0 {
            systemName = forceIcon
        }
        return HStack {
            Image(systemName: systemName)
                .resizable()
                .frame(width: isFolder ? 14 : 12, height: isFolder ? 12 : 15)
                .foregroundColor(color)
                .padding(.trailing, isFolder ? 4 : 6)
        }
    }

    // MARK: 计算背景色

    private var background: some View {
        if dragging {
            return Color.white.opacity(0.5)
        }

        if selected {
            #if os(macOS)
                return Color(.controlAccentColor)
            #endif

            #if os(iOS)
                return Color(.blue).opacity(0.8)
            #endif
        }

        if deleting == true {
            return Color(.gray).opacity(0.4)
        }

        if hovered {
            return Color(.controlAccentColor).opacity(0.1)
        }

        return Color.clear
    }

    private var foregroundColor: Color {
        selected == true ? Color.white : Color.primary
    }

    var body: some View {
        ZStack {
            background

            HStack(spacing: 2) {
                // MARK: 折叠指示器

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

                // MARK: 图标

                icon

                // MARK: 标题

                Text(title)
                    .foregroundColor(foregroundColor)

                Spacer()

                // MARK: 子节点数量

                Text(trailing)
                    .font(.footnote)
                    .foregroundColor(foregroundColor.opacity(0.8))
                    .opacity(isFolder ? 1 : 0)

                if deleting || loading {
                    ProgressView()
                        .controlSize(.mini)
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
//         如果定义了双击事件，单击的响应就会变慢
//        .onTapGesture(count: 2) {
//            collapsed.toggle()
//            clicked()
//        }
        .onTapGesture {
            // MARK: 双击事件

            if lastClickedAt.timeIntervalSinceNow > -0.5 {
                collapsed.toggle()
                return
            }

            // MARK: 单击事件

            lastClickedAt = .now
            selectionId = id
            clicked()
        }
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(hovered ? Color(.controlAccentColor).opacity(0) : Color.clear, lineWidth: 1)
        )
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

#Preview {
    VStack(spacing: 0) {
        MenuTile(
            id: UUID().uuidString,
            title: "普通",
            dragging: false,
            trailing: "",
            isFolder: false,
            deleting: Binding.constant(false),
            selectionId: Binding.constant("1"),
            collapsed: Binding.constant(false),
            forceIcon: Binding.constant("")
        )
        MenuTile(
            id: UUID().uuidString,
            title: "普通删除中",
            dragging: false,
            deleting: Binding.constant(true),
            selectionId: Binding.constant("1"),
            collapsed: Binding.constant(true),
            forceIcon: Binding.constant("")
        )
        MenuTile(
            id: UUID().uuidString,
            title: "普通加载中",
            dragging: false,
            loading: true,
            deleting: Binding.constant(false),
            selectionId: Binding.constant("1"),
            collapsed: Binding.constant(true),
            forceIcon: Binding.constant("")
        )
        MenuTile(
            id: UUID().uuidString,
            title: "普通目录",
            dragging: false,
            isFolder: true,
            deleting: Binding.constant(false),
            selectionId: Binding.constant("1"),
            collapsed: Binding.constant(true),
            forceIcon: Binding.constant("")
        )
        MenuTile(
            id: UUID().uuidString,
            title: "选中目录",
            dragging: false,
            isFolder: true,
            deleting: Binding.constant(false),
            selectionId: Binding.constant("1"),
            collapsed: Binding.constant(false),
            forceIcon: Binding.constant("")
        )
        MenuTile(
            id: UUID().uuidString,
            title: "普通带尾部",
            dragging: false,
            trailing: "9",
            deleting: Binding.constant(false),
            selectionId: Binding.constant("1"),
            collapsed: Binding.constant(false),
            forceIcon: Binding.constant("")
        )
        MenuTile(
            id: UUID().uuidString,
            title: "选中",
            dragging: false,
            deleting: Binding.constant(false),
            selectionId: Binding.constant("1"),
            collapsed: Binding.constant(false),
            forceIcon: Binding.constant("")
        )
        MenuTile(
            id: UUID().uuidString,
            title: "展开",
            dragging: false,
            deleting: Binding.constant(false),
            selectionId: Binding.constant("1"),
            collapsed: Binding.constant(false),
            forceIcon: Binding.constant("")
        )
        MenuTile(
            id: UUID().uuidString,
            title: "选中带尾部",
            dragging: false,
            trailing: "89",
            deleting: Binding.constant(false),
            selectionId: Binding.constant("1"),
            collapsed: Binding.constant(false),
            forceIcon: Binding.constant("")
        )
        MenuTile(
            id: UUID().uuidString,
            title: "普通",
            dragging: false,
            trailing: "",
            isFolder: false,
            deleting: Binding.constant(false),
            selectionId: Binding.constant("1"),
            collapsed: Binding.constant(false),
            forceIcon: Binding.constant("")
        )
        MenuTile(
            id: UUID().uuidString,
            title: "选中展开",
            dragging: false,
            deleting: Binding.constant(false),
            selectionId: Binding.constant("1"),
            collapsed: Binding.constant(false),
            forceIcon: Binding.constant("")
        )
    }
    .frame(width: 300)
    .padding(.all, 8)
}
