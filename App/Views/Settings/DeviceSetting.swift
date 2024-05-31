import SwiftUI
import OSLog

struct DeviceSetting: View {
    @State var playTime = 0
    @State var items: [DeviceData] = []
    
    var label: String {
        "\(Logger.isMain)🖥️ DeviceSetting::"
    }
    
    var body: some View {
        GroupBox {
            VStack {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("设备").font(.headline)
                        Spacer()
                    }
                }
                Spacer()
                ForEach(items, id: \.uuid) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        Text("\(item.timesOpened)")
                    }
                }
            }.padding(10)
        }.background(BackgroundView.type1.opacity(0.1))
            .onAppear {
                getItems()
            }
    }
    
    func getItems() {
        let db = DBSynced(AppConfig.getSyncedContainer)
        Task {
            let items = await db.allDevices()
            
            os_log("\(self.label)获取设备列表 -> \(items.count)")
            
            AppConfig.mainQueue.sync {
                self.items = items
            }
        }
    }
}

#Preview("APP") {
    AppPreview()
    .frame(height: 800)
}

#Preview {
    RootView {
        SettingView()
    }
    .frame(height: 800)
}

#Preview {
    DeviceSetting()
}
