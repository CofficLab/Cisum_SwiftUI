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
                        makeRow(i)
                        Divider().background(.background)
                    }
                    
                    if total > 0 {
                        Text("共 \(total.description)").foregroundStyle(.white)
                    }
                }
            }
        }
    }
    
    func makeRow(_ i: Int) -> some View {
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
