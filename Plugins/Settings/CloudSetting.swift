import OSLog
import SwiftUI
import MagicKit

struct CloudSetting: View {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var dataManager: DataProvider

    @State private var iCloudLogged: Bool = false
    @State private var iCloudEnabled: Bool = false

    var body: some View {
        GroupBox {
            Toggle(isOn: $iCloudEnabled) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("iCloud").font(.headline)

                        ZStack {
//                            if dataManager.isiCloudDisk {
//                                VStack(alignment: .leading) {
//                                    Text(iCloudLogged ? "iCloud 已登录" : "iCloud 未登录")
//                                    Text("会占用 iCloud 存储空间并在设备间保持同步")
//                                }
//                            } else {
//                                VStack(alignment: .leading) {
//                                    Text(iCloudLogged ? "iCloud 已登录，但不使用" : "iCloud 未登录")
//                                    Text("数据仅存储在本机")
//                                    Text("不占用 iCloud 空间")
//                                    Text("多设备不同步")
//                                }
//                            }
                        }
                        .font(.subheadline)
                        .opacity(0.8)
                    }
                    Spacer()
                }.padding(10)
            }
            .toggleStyle(.switch)
        }
        .background(BackgroundView.type1.opacity(0.1))
        .onAppear {
//            iCloudEnabled = dataManager.isiCloudDisk
            Config.ifLogged { result in
                iCloudLogged = result

                if !result {
                    iCloudEnabled = false
                }
            }
        }
        .onChange(of: iCloudEnabled, {
            Config.setiCloud(iCloudEnabled)
            
            do {
                iCloudEnabled ? try dataManager.enableiCloud() : try dataManager.disableiCloud()
            } catch let e {
                os_log(.error, "设置 iCloud 出错 -> \(e.localizedDescription)")
                Config.setiCloud(!iCloudEnabled)
            }
        })
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 1200)
}

#Preview("Setting") {
    RootView {
        SettingView()
            .background(.background)
    }.modelContainer(Config.getContainer)
        .frame(height: 1200)
}
