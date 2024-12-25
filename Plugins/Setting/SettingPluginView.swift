import SwiftUI

struct SettingPluginView: View, SuperSetting {
    @EnvironmentObject var c: ConfigProvider
    @State private var tempStorageLocation: StorageLocation

    init() {
        // 直接初始化为默认值 .local
        _tempStorageLocation = State(initialValue: .local)
    }

    var body: some View {
        makeSettingView(title: "媒体仓库位置") {
            VStack(alignment: .leading, spacing: 16) {
                // iCloud 选项
                RadioButton(
                    text: "iCloud 云盘",
                    description: "将媒体文件存储在 iCloud 云盘中，可在其他设备上访问",
                    isSelected: Binding(
                        get: { tempStorageLocation == .icloud },
                        set: { _ in tempStorageLocation = .icloud }
                    ),
                    trailing: {
                        AnyView(BtnOpenFolder(url: Config.coverDir).labelStyle(.iconOnly))
                    }
                )

                // APP 内部存储选项
                RadioButton(
                    text: "APP 内部存储",
                    description: "存储在 APP 中，删除 APP 后数据将丢失",
                    isSelected: Binding(
                        get: { tempStorageLocation == .local },
                        set: { _ in tempStorageLocation = .local }
                    ),
                    trailing: {
                        AnyView(BtnOpenFolder(url: Config.coverDir).labelStyle(.iconOnly))
                    }
                )

                // 自定义目录选项
                RadioButton(
                    text: "自定义目录",
                    description: "选择您想要存储的位置",
                    isSelected: Binding(
                        get: { tempStorageLocation == .custom },
                        set: { _ in tempStorageLocation = .custom }
                    ),
                    trailing: {
                        AnyView(BtnOpenFolder(url: Config.coverDir).labelStyle(.iconOnly))
                    }
                )

                // 添加保存按钮
                Button(action: {
                    c.updateStorageLocation(tempStorageLocation)
                }) {
                    Text("保存更改")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 16)
            }
            .padding(.vertical, 8)
            .onAppear {
                // 在视图出现时更新临时存储位置
                tempStorageLocation = c.storageLocation ?? .local
            }
        } trailing: {
            if let root = c.getStorageRoot() {
                BtnOpenFolder(url: root).labelStyle(.iconOnly)
            }
        }
    }
}

// 自定义 RadioButton 组件
struct RadioButton: View {
    // 基础属性
    let title: String
    let description: String
    let isSelected: Binding<Bool>
    let trailing: (() -> AnyView)?

    // 简化初始化器
    init(
        text: String,
        description: String,
        isSelected: Binding<Bool>,
        trailing: (() -> AnyView)? = nil
    ) {
        self.title = text
        self.description = description
        self.isSelected = isSelected
        self.trailing = trailing
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                // 单选按钮图标
                Image(systemName: isSelected.wrappedValue ? "circle.inset.filled" : "circle")
                    .foregroundColor(isSelected.wrappedValue ? .accentColor : .secondary)
                    .imageScale(.medium)

                // 文本内容
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.headline)

                        Spacer()

                        if let trailing {
                            trailing()
                        }
                    }

                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isSelected.wrappedValue = true
            }

            // 添加分隔线
            Divider()
                .background(.background)
                .padding(.top, 4)
        }
    }
}
