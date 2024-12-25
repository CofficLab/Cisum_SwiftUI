import SwiftUI
import MagicKit

struct SettingPluginView: View, SuperSetting {
    @EnvironmentObject var c: ConfigProvider
    @State private var showMigrationAlert = false
    @State private var showMigrationProgress = false
    @State private var migrationProgress = 0.0
    @State private var currentMigratingFile = ""
    @State private var tempStorageLocation: StorageLocation
    @State var diskSize: String?
    @State private var errorMessage: String?
    @State private var showErrorAlert = false

    init() {
        // 直接初始化为默认值 .local
        _tempStorageLocation = State(initialValue: .local)
    }

    var errorAlertMessage: String {
        """
        \(errorMessage ?? "未知错误")
        
        存储位置已重置为原位置，未做更改。
        
        建议：
        1. 请检查新旧仓库的权限和空间
        2. 可以手动查看并处理两个仓库中的数据
        3. 确认问题解决后再尝试迁移
        """
    }

    var body: some View {
        makeSettingView(title: "📺 媒体仓库位置") {
            VStack(alignment: .leading, spacing: 16) {
                // iCloud 选项
                RadioButton(
                    text: "iCloud 云盘",
                    description: "将媒体文件存储在 iCloud 云盘中，可在其他设备上访问。确保 iCloud 账户已登录且存储空间足够",
                    url: c.getStorageRoot(for: .icloud),
                    isSelected: Binding(
                        get: { tempStorageLocation == .icloud },
                        set: { _ in tempStorageLocation = .icloud }
                    ),
                    trailing: {
                        AnyView(
                            HStack {
                                Text("推荐").font(.footnote)
                            }
                        )
                    }
                )

                // APP 内部存储选项
                RadioButton(
                    text: "APP 内部存储",
                    description: "存储在 APP 中，删除 APP 后数据将丢失",
                    url: c.getStorageRoot(for: .local),
                    isSelected: Binding(
                        get: { tempStorageLocation == .local },
                        set: { _ in tempStorageLocation = .local }
                    )
                )

                // 自定义目录选项
                RadioButton(
                    text: "自定义目录",
                    description: "选择您想要存储的位置",
                    url: c.getStorageRoot(for: .custom),
                    isSelected: Binding(
                        get: { tempStorageLocation == .custom },
                        set: { _ in tempStorageLocation = .custom }
                    )
                )

                // 添加保存按钮
                Button(action: {
                    showMigrationAlert = true
                }) {
                    Text("保存更改")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 16)
                .alert("迁移数据", isPresented: $showMigrationAlert) {
                    Button("迁移数据", role: .destructive) {
                        showMigrationProgress = true
                        Task {
                            do {
                                try await c.migrateAndUpdateStorageLocation(
                                    to: tempStorageLocation,
                                    shouldMigrate: true,
                                    progressCallback: { progress, file in
                                        migrationProgress = progress
                                        currentMigratingFile = file
                                    }
                                )
                                showMigrationProgress = false
                            } catch {
                                showMigrationProgress = false
                                errorMessage = error.localizedDescription
                                showErrorAlert = true
                                // 重置为当前实际的存储位置
                                tempStorageLocation = c.storageLocation ?? .local
                            }
                        }
                    }
                    Button("不迁移", role: .cancel) {
                        Task {
                            do {
                                try await c.migrateAndUpdateStorageLocation(
                                    to: tempStorageLocation,
                                    shouldMigrate: false,
                                    progressCallback: nil
                                )
                            } catch {
                                errorMessage = error.localizedDescription
                                showErrorAlert = true
                                // 重置为当前实际的存储位置
                                tempStorageLocation = c.storageLocation ?? .local
                            }
                        }
                    }
                } message: {
                    Text("是否将现有数据迁移到新位置？\n选择\"不迁移\"将在新位置创建空白仓库。")
                }
            }
            .sheet(isPresented: $showMigrationProgress) {
                MigrationProgressView(
                    progress: migrationProgress,
                    currentFile: currentMigratingFile
                )
            }
            .alert("迁移失败", isPresented: $showErrorAlert) {
                Button("打开当前仓库", role: .none) {
                    if let root = c.getStorageRoot() {
                        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: root.path)
                    }
                }
                Button("打开目标仓库", role: .none) {
                    if let root = c.getStorageRoot(for: tempStorageLocation) {
                        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: root.path)
                    }
                }
                Button("确定", role: .cancel) { }
            } message: {
                Text(errorAlertMessage)
            }
            .padding(.vertical, 8)
            .onAppear {
                // 在视图出现时更新临时存储位置
                tempStorageLocation = c.storageLocation ?? .local
            }
        } trailing: {
            HStack {
                if let diskSize = diskSize {
                    Text(diskSize)
                }
            }
        }
        .task {
            if let root = c.getStorageRoot() {
                diskSize = FileHelper.getFileSizeReadable(root)
            }
        }
    }
}

// 自定义 RadioButton 组件
struct RadioButton: View {
    let title: String
    let description: String
    let url: URL?
    let isSelected: Binding<Bool>
    let trailing: (() -> AnyView)?

    init(
        text: String,
        description: String,
        url: URL?,
        isSelected: Binding<Bool>,
        trailing: (() -> AnyView)? = nil
    ) {
        self.title = text
        self.description = description
        self.url = url
        self.isSelected = isSelected
        self.trailing = trailing
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: isSelected.wrappedValue ? "circle.inset.filled" : "circle")
                    .foregroundColor(isSelected.wrappedValue ? .accentColor : .secondary)
                    .imageScale(.medium)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 4) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(title)
                                .font(.headline)

                            Spacer()

                            if let trailing {
                                trailing()
                            }
                        }
                        .padding(.bottom)

                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom)
                        
                        HStack {
                            Text(url?.path ?? "未设置路径")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(nil)
                            Spacer()
                            
                            if let url = url {
                                BtnOpenFolder(url: url).labelStyle(.iconOnly)
                            }
                        }
                        .padding(8)
                        .background(BackgroundView.type2A.opacity(0.2))
                        .cornerRadius(6)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isSelected.wrappedValue = true
            }

            Divider()
                .background(.background)
                .padding(.top, 4)
        }
    }
}
