import SwiftUI
import OSLog
import SwiftData
import MagicKit
import MagicUI

struct DeviceSetting: View, @preconcurrency SuperLog {
    @Environment(\.modelContext) private var modelContext
    
    @State var playTime = 0
    @Query(sort: \DeviceData.timesOpened, order: .reverse) var items: [DeviceData]

    var verbose: Bool = false
    
    static let emoji: String = "🖥️"
    
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
        .background(MagicBackground.aurora.opacity(0.1))
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
