import SwiftUI
import SwiftData
import OSLog

struct DBVStackView: View {
    @EnvironmentObject var audioManager: AudioManager
    @Environment(\.modelContext) private var modelContext
    
    @State var total: Int = 0

    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(0...max(0, total-1), id: \.self) { i in
                        makeRow(i).padding(.horizontal)
                        Divider()
                    }
                }
                .padding(.vertical)
            }
            .background(.background)
        }.onAppear {
            refresh()
        }
    }
    
    func refresh() {
        getTotal()
        if total > 0 && audioManager.isEmpty {
            if let audio = getItemFromDB(0) {
                audioManager.setCurrent(audio)
            }
        }
    }
    
    func getTotal() {
        let predicate = #Predicate<PlayItem> {
            $0.order != -1
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        do {
            let result = try modelContext.fetchCount(descriptor)
            total = result
        } catch {
            total = 0
        }
    }
    
    func makeRow(_ i: Int) -> some View {
//        os_log("🖥️ 渲染 \(i)")
        return ZStack {
            if let item = getItemFromDB(i) {
                Row(Audio(item.url))
            }
        }
    }
    
    func getItemFromDB(_ i: Int) -> PlayItem? {
        // 创建一个 FetchDescriptor 查询特定行
        var descriptor = FetchDescriptor<PlayItem>()
        descriptor.fetchLimit = 1 // 限制查询结果为1条记录
        descriptor.fetchOffset = i // 设置偏移量，从0开始
        do {
            let result = try modelContext.fetch(descriptor)
            if let first = result.first {
                return first
            } else {
                print("not found")
            }
        } catch let e{
            print(e)
        }
        
        return nil
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
