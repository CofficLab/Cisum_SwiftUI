import SwiftUI

struct SettingPluginView: View {
    @EnvironmentObject var c: ConfigProvider

    var body: some View {
        Form(content: {
            Section(content: {
                VStack(alignment: .leading, spacing: 16) {
                    // iCloud 选项
                    RadioButton(
                        id: .icloud,
                        text: "iCloud 云盘",
                        description: "将媒体文件存储在 iCloud 云盘中，可在其他设备上访问",
                        isSelected: Binding(
                            get: { c.storageLocation == .icloud },
                            set: { _ in c.updateStorageLocation(.icloud) }
                        )
                    ) {
                        Button("打开 iCloud 文件夹") {
                            // TODO: 实现打开 iCloud 文件夹的逻辑
                        }
                        .buttonStyle(.bordered)
                    }

                    // APP 内部存储选项
                    SimpleRadioButton(
                        id: .local,
                        text: "APP 内部存储",
                        description: "存储在 APP 中，删除 APP 后数据将丢失",
                        isSelected: Binding(
                            get: { c.storageLocation == .local },
                            set: { _ in c.updateStorageLocation(.local) }
                        )
                    )

                    // 自定义目录选项
                    RadioButton(
                        id: .custom,
                        text: "自定义目录",
                        description: "选择您想要存储的位置",
                        isSelected: Binding(
                            get: { c.storageLocation == .custom },
                            set: { _ in c.updateStorageLocation(.custom) }
                        )
                    ) {
                        Button("选择目录") {
                            // TODO: 实现选择目录的逻辑
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.vertical, 8)
            }, header: {
                Text("媒体仓库位置")
            })
        })
        .padding()
        .background(.background)
        .cornerRadius(10)
    }
}

// 自定义 RadioButton 组件
struct RadioButton<Content: View>: View {
    let id: StorageLocation
    let text: String
    let description: String
    let isSelected: Binding<Bool>
    let additionalContent: (() -> Content)?

    init(
        id: StorageLocation,
        text: String,
        description: String,
        isSelected: Binding<Bool>,
        additionalContent: (() -> Content)? = nil
    ) {
        self.id = id
        self.text = text
        self.description = description
        self.isSelected = isSelected
        self.additionalContent = additionalContent
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: isSelected.wrappedValue ? "circle.inset.filled" : "circle")
                    .foregroundColor(isSelected.wrappedValue ? .accentColor : .secondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(text)
                        .font(.headline)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .onTapGesture {
                isSelected.wrappedValue = true
            }

            if let additionalContent = additionalContent {
                additionalContent()
                    .padding(.leading, 28)
            }
        }
    }
}

// 创建一个便利的类型别名，用于没有额外内容的 RadioButton
typealias SimpleRadioButton = RadioButton<EmptyView>
