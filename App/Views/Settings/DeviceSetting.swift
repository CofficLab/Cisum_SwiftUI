import SwiftUI
import OSLog
import SwiftData

struct DeviceSetting: View {
    @Environment(\.modelContext) private var modelContext
    
    @State var playTime = 0
    @Query(sort: \DeviceData.timesOpened, order: .reverse) var items: [DeviceData]

    var verbose: Bool = false
    
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
//                        BtnDelDevice(deviceData: item).labelStyle(.iconOnly)
                    }
                }
            }.padding(10)
        }
        .background(BackgroundView.type1.opacity(0.1))
    }
}

#Preview("APP") {
    AppPreview()
    .frame(height: 800)
}

#Preview {
    BootView {
        SettingView()
    }
    .frame(height: 800)
}

#Preview {
    DeviceSetting()
}
