import MagicCore
import OSLog
import SwiftUI

struct StorageView: View, SuperLog {
    nonisolated static let emoji = "🍴"

    @EnvironmentObject var cloudManager: CloudProvider
    @EnvironmentObject var c: ConfigProvider
    @EnvironmentObject var a: AppProvider

    @State private var showMigrationProgress = false
    @State private var tempStorageLocation: StorageLocation
    @State private var hasChanges = false
    @State private var storageRoot: URL?

    init() {
        _tempStorageLocation = State(initialValue: StorageLocation.icloud)
    }

    var body: some View {
        MagicSettingSection(title: "媒体仓库位置") {
            VStack(alignment: .leading, spacing: 20) {
                RadioButton(
                    text: "☁️ iCloud 云盘",
                    description: "将媒体文件存储在 iCloud 云盘中\n可在其他设备上访问\n确保 iCloud 账户已登录且存储空间足够",
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
                    isEnabled: cloudManager.isSignedIn == true && c.storageLocation != .icloud,
                    disabledReason: "在系统设置中登录 iCloud 账户后，此选项可用"
                )

                RadioButton(
                    text: "💾 APP 内部存储",
                    description: "存储在 APP 中，删除 APP 后数据将丢失",
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

                MagicButton.simple(
                    icon: .iconCheckmark,
                    title: "应用更改",
                    style: .primary,
                    size: .auto,
                    shape: .roundedRectangle,
                    disabledReason: hasChanges ? nil : "无更改"
                ) {
                    c.updateStorageLocation(tempStorageLocation)
                    a.showSheet = false
                }
                .magicShapeVisibility(.always)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .padding(.top, 8)
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
            .animation(.easeInOut(duration: 0.2), value: hasChanges)
            .animation(.easeInOut(duration: 0.2), value: tempStorageLocation)
        }
    }
}

#Preview("Welcome") {
    RootView {
        WelcomeView()
    }
    .frame(height: 800)
}

#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 500, height: 800)
}

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif
