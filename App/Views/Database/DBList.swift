import SwiftUI
import SwiftData
import OSLog

struct DBList: View {
    @EnvironmentObject var audioManager: AudioManager
    
    @State var total: Int = 0
    @State var updatedAt: Date = .now

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing:0) {
                    ForEach(0...max(0, total-1), id: \.self) { i in
                        makeRow(i)
                        Divider().background(.background)
                    }
                    
                    if total > 0 {
                        Text("共 \(total.description)").foregroundStyle(.white)
                    }
                }
            }
        }.onAppear {
            refresh()
        }.onChange(of: audioManager.lastUpdatedAt, {
            //os_log("🖥️ DBVStackView:需要刷新")
            updatedAt = .now
            refresh()
        })
    }
    
    func refresh() {
        self.total = audioManager.db?.getTotal() ?? 0
        if total > 0 && audioManager.isEmpty {
            if let audio = audioManager.db?.getFirstValid() {
//                audioManager.setCurrent(audio)
            }
        }
    }
    
    func makeRow(_ i: Int) -> some View {
//        os_log("🖥️ 渲染 \(i)")
        return ZStack {
            if let item = audioManager.db?.get(i) {
                Row(item)
            }
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
