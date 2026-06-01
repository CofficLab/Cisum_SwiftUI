import CisumUI
import MagicKit
import SwiftUI

struct CrashedView: View {
    @EnvironmentObject var cloud: CloudProvider

    var error: Error

    @State private var showAlert = false
    @State private var isCopied = false

    var body: some View {
        ScrollView {
            VStack {
                Spacer(minLength: 20)

                Image.cisumCoffeeReelIcon(useDefaultBackground: false)
                    .scaledToFit()
                    .background(
                        Circle()
                            .fill(.red.opacity(0.1))
                    )
                    .frame(maxHeight: 120)

                Spacer()

                VStack {
                    Text("Unable to continue", tableName: "Core")
                        .font(.title)
                        .padding(.bottom, 10)

                    GroupBox {
                        Text(String(describing: type(of: error)))
                            .padding(.top, 20)
                            .padding(.bottom, 20)
                            .font(.title2)

                        Text("\(error.localizedDescription)", tableName: "Core")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                            .padding(.bottom, 10)

                        // 复制错误信息按钮
                        Button(action: {
                            copyErrorToClipboard()
                        }) {
                            HStack {
                                Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc")
                                    .foregroundColor(isCopied ? .green : .blue)
                                Text(isCopied ? "Copied" : "Copy Error Details", tableName: "Core")
                                    .foregroundColor(isCopied ? .green : .blue)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.1))
                                    .stroke(isCopied ? Color.green : Color.blue, lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .scaleEffect(isCopied ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isCopied)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                    }.padding()

                    Spacer()

                    debugView

                    #if os(macOS)
                        Button {
                            NSApplication.shared.terminate(self)
                        } label: {
                            Text("Quit", tableName: "Core")
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
                    makeKeyValueItem(key: String(localized: "iCloud Drive Enabled", table: "Core"), value: MagicApp.isICloudAvailable() ? String(localized: "Yes", table: "Core") : String(localized: "No", table: "Core"))
                    Divider()
                    makeKeyValueItem(key: String(localized: "iCloud Sign In", table: "Core"), value: cloud.isSignedInDescription)
                }
            }, header: { makeTitle("iCloud") })

            Section(content: {
                GroupBox {
                    makeKeyValueItem(key: String(localized: "Storage Location", table: "Core"), value: Config.getStorageLocation()?.title ?? String(localized: "Not Set", table: "Core"))
                }
            }, header: { makeTitle("Settings") })

            Section(content: {
                GroupBox {
                    makeKeyValueItem(key: String(localized: "App Container", table: "Core"), value: MagicApp.getContainerDirectory().path(percentEncoded: false))
                    makeKeyValueItem(key: String(localized: "Database Folder", table: "Core"), value: MagicApp.getDatabaseDirectory().path(percentEncoded: false))
                }
            }, header: { makeTitle("Folders") })

            GroupBox {
                Button {
                    Config.resetStorageLocation()
                    showAlert = true
                } label: {
                    Text("Restore Defaults", tableName: "Core")
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Notice", tableName: "Core"),
                        message: Text("Please quit the app, then open it again.", tableName: "Core"),
                        dismissButton: .default(Text("OK", tableName: "Core"))
                    )
                }
            }
        }.padding(20)
    }

    private func makeTitle(_ title: LocalizedStringKey) -> some View {
        HStack {
            Text(title, tableName: "Core").font(.headline).padding(.leading, 10)
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

    /// 复制错误信息到剪贴板
    private func copyErrorToClipboard() {
        Self.errorDetailsText(error).copy()

        // 显示复制成功状态
        withAnimation {
            isCopied = true
        }

        // 2秒后重置状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                isCopied = false
            }
        }
    }

    nonisolated static func errorDetailsText(_ error: Error) -> String {
        """
        Error type: \(String(describing: type(of: error)))
        Error description: \(error.localizedDescription)
        """
    }
}

// MARK: - Private Helpers

extension CrashedView {
    private func isFileExist(_ url: URL) -> String {
        FileManager.default.fileExists(atPath: url.path) ? "是" : "否"
    }

    private func isDirExist(_ url: URL) -> String {
        var isDir: ObjCBool = true
        return FileManager.default.fileExists(atPath: url.path(), isDirectory: &isDir) ? "是" : "否"
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}

#if DEBUG
    #if os(macOS)
        #Preview("ErrorViewFatal - Large") {
            CrashedView(error: NSError(domain: "TestError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "这是一个测试错误，用于预览界面效果"]))
                .inRootView()
                .frame(width: 600, height: 1000)
        }

        #Preview("ErrorViewFatal - Small") {
            CrashedView(error: NSError(domain: "TestError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "测试错误"]))
                .inRootView()
                .frame(width: 500, height: 800)
        }
    #endif

    #if os(iOS)
        #Preview("ErrorViewFatal - iPhone") {
            CrashedView(error: NSError(domain: "TestError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "这是一个测试错误，用于预览界面效果"]))
                .inRootView()
        }
    #endif

    #Preview("App - Large") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        ContentView()
            .inRootView()
            .frame(width: 500, height: 800)
    }

    #if os(iOS)
        #Preview("iPhone") {
            ContentView()
                .inRootView()
        }
    #endif
#endif
