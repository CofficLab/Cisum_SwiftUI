import OSLog
import SwiftUI

struct CloudSetting: View {
  @EnvironmentObject var app: AppManager
  @EnvironmentObject var dataManager: DataManager

  @State private var iCloudLogged: Bool = false
  @State private var iCloudEnabled: Bool = false

  var body: some View {
    GroupBox {
      Toggle(isOn: $iCloudEnabled) {
        HStack {
          VStack(alignment: .leading, spacing: 5) {
            Text("iCloud").font(.headline)

            ZStack {
              if iCloudEnabled {
                Text("会占用 iCloud 存储空间并在设备间保持同步")
              } else {
                VStack(alignment: .leading) {
                  Text("数据仅存储在本机")
                  Text("不占用 iCloud 空间")
                  Text("多设备不同步")
                }
              }
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
      iCloudEnabled = Config.iCloudEnabled
      Config.ifLogged { result in
        iCloudLogged = result

        if !result {
          iCloudEnabled = false
        }
      }
    }
    .onChange(
      of: iCloudEnabled,
      {
        iCloudEnabled ? Config.enableiCloud() : Config.disableiCloud()

//        dataManager.changeDisk(Config.disk)

        Task.detached(operation: {
            await dataManager.migrate()
        })
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
