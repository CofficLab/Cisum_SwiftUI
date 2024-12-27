import SwiftUI
import MagicKit
import MagicUI
import OSLog

struct SettingPluginView: View, SuperSetting, SuperLog {
    static var emoji: String = "🍴"
    
    @EnvironmentObject var cloudManager: CloudProvider
    @EnvironmentObject var c: ConfigProvider
    
    @State private var showMigrationProgress = false
    @State private var tempStorageLocation: StorageLocation
    @State private var hasChanges = false
    @State private var storageRoot: URL?
    
    init() {
        _tempStorageLocation = State(initialValue: .local)
    }
    
    var body: some View {
        makeSettingView(title: "📺 媒体仓库位置") {
            VStack(alignment: .leading, spacing: 16) {
                // iCloud 选项
                RadioButton(
                    text: "iCloud 云盘",
                    description: "☁️ 将媒体文件存储在 iCloud 云盘中 \n🔄 可在其他设备上访问 \n🗄️ 确保 iCloud 账户已登录且存储空间足够",
                    url: c.getStorageRoot(for: .icloud),
                    isSelected: Binding(
                        get: { tempStorageLocation == .icloud },
                        set: { _ in tempStorageLocation = .icloud }
                    ),
                    trailing: {
                        AnyView(
                            HStack {
                                Text("推荐").font(.footnote)
                                
                                if c.storageLocation == .icloud {
                                    Text("当前").font(.footnote)
                                }
                            }
                        )
                    },
                    isEnabled: cloudManager.isSignedIn || c.storageLocation != .icloud,
                    disabledReason: "在系统设置中登录 iCloud 账户后，此选项可用"
                )

                // APP 内部存储选项
                RadioButton(
                    text: "APP 内部存储",
                    description: "🛖 存储在 APP 中，删除 APP 后数据将丢失",
                    url: c.getStorageRoot(for: .local),
                    isSelected: Binding(
                        get: { tempStorageLocation == .local },
                        set: { _ in tempStorageLocation = .local }
                    ),
                    trailing: {
                        AnyView(
                            HStack {
                                if c.storageLocation == .local {
                                    Text("当前").font(.footnote)
                                }
                            }
                        )
                    }
                )

                // 自定义目录选项
//                RadioButton(
//                    text: "自定义目录",
//                    description: "选择您想要存储的位置",
//                    url: c.getStorageRoot(for: .custom),
//                    isSelected: Binding(
//                        get: { tempStorageLocation == .custom },
//                        set: { _ in tempStorageLocation = .custom }
//                    )
//                )

                // 添加保存按钮
                Button(action: {
                    showMigrationProgress = true
                }) {
                    Text("准备迁移")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!hasChanges)
                .padding(.top, 16)
            }
            .sheet(isPresented: $showMigrationProgress) {
                MigrationProgressView(
                    sourceLocation: c.storageLocation ?? .local,
                    targetLocation: tempStorageLocation,
                    sourceURL: c.getStorageRoot(),
                    targetURL: c.getStorageRoot(for: tempStorageLocation),
                    onDismiss: {
                        showMigrationProgress = false
                        self.hasChanges = tempStorageLocation != c.storageLocation
                        storageRoot = c.getStorageRoot()

                        os_log("\(self.t) Current Storage Root \(storageRoot?.path ?? "nil")")
                    }
                )
            }
            .padding(.vertical, 8)
            .onAppear {
                tempStorageLocation = c.storageLocation ?? .local
                hasChanges = false
                storageRoot = c.getStorageRoot()
            }
            .onChange(of: tempStorageLocation) {
                hasChanges = tempStorageLocation != (c.storageLocation ?? .local)
                storageRoot = c.getStorageRoot()
            }
        } trailing: {
            HStack {
                if let root = storageRoot {
                    FileSizeView(url: root)
                        .id(root.path)
                    BtnOpenFolder(url: root).labelStyle(.iconOnly)
                }
            }
        }
    }
}
