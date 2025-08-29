import MagicCore
import OSLog
import SwiftUI

struct StorageView: View, SuperLog {
    nonisolated static let emoji = "🍴"

    @EnvironmentObject var cloudManager: CloudProvider
    @EnvironmentObject var c: ConfigProvider
    @EnvironmentObject var a: AppProvider

    @State private var tempStorageLocation: StorageLocation

    init() {
        _tempStorageLocation = State(initialValue: StorageLocation.icloud)
    }

    var body: some View {
        MagicSettingSection(title: "媒体仓库位置", titleAlignment: .center) {
            VStack(alignment: .leading, spacing: 20) {
                RadioButton(
                    text: "☁️ iCloud 云盘",
                    description: "将媒体文件存储在 iCloud 云盘中\n可在其他设备上访问\n确保 iCloud 账户已登录且存储空间足够",
                    url: c.getStorageRoot(for: .icloud),
                    isSelected: Binding(
                        get: { tempStorageLocation == .icloud },
                        set: { _ in
                            tempStorageLocation = .icloud
                            c.updateStorageLocation(.icloud)
                        }
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
                        set: { _ in
                            tempStorageLocation = .local
                            c.updateStorageLocation(.local)
                        }
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
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .onAppear {
                // 自动设置存储位置
                autoSetStorageLocation()
            }
        }
    }

    // MARK: - 自动设置存储位置

    private func autoSetStorageLocation() {
        // 如果已经有存储位置设置，则使用现有设置
        if let currentLocation = c.storageLocation {
            tempStorageLocation = currentLocation
            return
        }

        // 如果没有设置，则自动选择
        if cloudManager.isSignedIn == true {
            // iCloud 可用，选择 iCloud
            tempStorageLocation = .icloud
            c.updateStorageLocation(.icloud)
        } else {
            // iCloud 不可用，选择本地存储
            tempStorageLocation = .local
            c.updateStorageLocation(.local)
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
