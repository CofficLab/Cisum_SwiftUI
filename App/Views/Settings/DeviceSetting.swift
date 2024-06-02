import SwiftUI
import OSLog
import SwiftData

struct DeviceSetting: View {
    @State var playTime = 0
    @Query var items: [DeviceData]
    
    @Environment(\.modelContext) private var modelContext
    
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
    RootView {
        SettingView()
    }
    .frame(height: 800)
}

#Preview {
    DeviceSetting()
}
