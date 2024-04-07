import SwiftUI
import SwiftData
import OSLog

struct DBList: View {
    @EnvironmentObject var audioManager: AudioManager
    
    var total: Int {audioManager.db?.getTotal() ?? 0}

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
            LazyVStack(spacing:0) {
                    ForEach(0...max(0, total-1), id: \.self) { i in
                        ZStack {
                            if let item = audioManager.db?.get(i) {
//                                Row(item)
                                Text("\(i) \(item.title)")
                            }
                        }
                        Divider().background(.background)
                    }
                    
                    if total > 0 {
                        Text("共 \(total.description)").foregroundStyle(.white)
                    }
                }
            }
        }
//        .onAppear {
//            NotificationCenter.default.addObserver(
//                forName: NSNotification.Name("Updated"),
//                object: nil,
//                queue: .main,
//                using: { notification in
//                    AppConfig.bgQueue.async {
//                        let data = notification.userInfo as! [String: [MetadataItemWrapper]]
//                        let items = data["items"]!
//                        os_log("\(Logger.isMain)🖥️ Row::detect updated of count=\(items.count)")
//                    }
//                })
//        }
//        .onDisappear {
//            NotificationCenter.default.removeObserver(self)
//        }
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
