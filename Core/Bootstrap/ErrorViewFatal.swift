import MagicKit
import MagicUI
import SwiftUI

struct ErrorViewFatal: View {
    @EnvironmentObject var c: ConfigProvider
    @EnvironmentObject var cloud: CloudProvider

    var error: Error

    @State private var showAlert = false

    var body: some View {
        ScrollView {
            VStack {
                Spacer(minLength: 20)

                Image("PlayingAlbum")
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .frame(maxHeight: 150)

                Spacer()

                VStack {
                    Text("遇到问题无法继续运行")
                        .font(.title)
                        .padding(.bottom, 10)

                    Text("\(error.localizedDescription)")
                        .font(.subheadline)
                        .padding(.bottom, 10)

                    Text(String(describing: type(of: error)))
                        .padding(.bottom, 10)

                    Text(String(describing: error))

                    Spacer()

                    debugView

                    #if os(macOS)
                        Button("退出") {
                            NSApplication.shared.terminate(self)
                        }.controlSize(.extraLarge)

                        Spacer()
                    #endif
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background.opacity(0.8))
    }

    var debugView: some View {
        VStack(spacing: 10) {
            Section(content: {
                GroupBox {
                    makeKeyValueItem(key: "启用iCloud云盘", value: iCloudHelper.iCloudDiskEnabled() ? "是" : "否")
                    Divider()
                    makeKeyValueItem(key: "登录 iCloud", value: cloud.isSignedInDescription)
                }
            }, header: { makeTitle("iCloud") })

            Section(content: {
                GroupBox {
                    makeKeyValueItem(key: "仓库位置", value: c.storageLocation?.title ?? "未设置")
                }
            }, header: { makeTitle("设置") })

            GroupBox {
                Button("恢复默认设置") {
                    c.resetStorageLocation()
                    showAlert = true
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("提示"),
                        message: Text("请退出 APP，再重新打开"),
                        dismissButton: .default(Text("确定"))
                    )
                }
            }
        }.padding(20)
    }

    private func makeTitle(_ title: String) -> some View {
        HStack {
            Text(title).font(.headline).padding(.leading, 10)
            Spacer()
        }
    }

    private func makeKeyValueItem(key: String, value: String) -> some View {
        HStack(content: {
            VStack(alignment: .leading, spacing: 5) {
                Text(key)
                Text(value)
                    .font(.footnote)
                    .opacity(0.8)
            }
            Spacer()
        }).padding(5)
    }

    private func isFileExist(_ url: URL) -> String {
        FileManager.default.fileExists(atPath: url.path) ? "是" : "否"
    }

    private func isDirExist(_ url: URL) -> String {
        var isDir: ObjCBool = true
        return FileManager.default.fileExists(atPath: url.path(), isDirectory: &isDir) ? "是" : "否"
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
