import SwiftUI

struct SettingView: View {
    var body: some View {
        ScrollView {
            VStack {
                GroupBox {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("仓库目录").font(.headline)
                            Text(AppConfig.audiosDir.absoluteString)
                                .font(.subheadline)
                                .opacity(0.8)
                            if iCloudHelper.isCloudPath(url: AppConfig.audiosDir) {
                                Text("是iCloud云盘目录，会保持同步").font(.footnote)
                            } else {
                                Text("是本地目录，不会同步").font(.footnote)
                            }
                        }
                        Spacer()
                        Button(action: {
                            openUrl(AppConfig.audiosDir)
                        }, label: {
                            Label(title: {
                                Text("打开")
                            }, icon: {
                                Image(systemName: "doc.viewfinder.fill")
                            })
                        })
                    }.padding(10)
                }.background(BackgroundView.type1.opacity(0.1))

                GroupBox {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("封面图目录").font(.headline)
                            Text(AppConfig.coverDir.absoluteString)
                                .font(.subheadline)
                                .opacity(0.8)
                            Text("根据音频文件自动生成封面图").font(.footnote)
                        }
                        Spacer()
                        Button(action: {
                            openUrl(AppConfig.coverDir)
                        }, label: {
                            Label(title: {
                                Text("打开")
                            }, icon: {
                                Image(systemName: "doc.viewfinder.fill")
                            })
                        })
                    }.padding(10)
                }.background(BackgroundView.type1.opacity(0.1))
            }
        }
        .background(.background)
    }

    private func openUrl(_ url: URL?) {
        #if os(macOS)
            guard let dir = url else {
                // 显示错误提示
                let errorAlert = NSAlert()
                errorAlert.messageText = "打开目录出错"
                errorAlert.informativeText = "目录不存在"
                errorAlert.alertStyle = .critical
                errorAlert.addButton(withTitle: "好的")
                errorAlert.runModal()

                return
            }

            NSWorkspace.shared.open(dir)
        #endif
    }
}

#Preview {
    SettingView()
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}