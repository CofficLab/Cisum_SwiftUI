import SwiftUI
import SwiftData
import OSLog

struct DBList: View {
    @EnvironmentObject var audioManager: AudioManager
    @Environment(\.modelContext) private var modelContext
    
    @State var total: Int = 0
    @State var updatedAt: Date = .now

    var body: some View {
        VStack(spacing: 0) {
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
            
            Text("共 \(total)")
        }.onAppear {
            refresh()
        }.onChange(of: audioManager.lastUpdatedAt, {
            os_log("🖥️ DBVStackView:需要刷新")
            updatedAt = .now
            refresh()
        })
    }
    
    func refresh() {
        getTotal()
        if total > 0 && audioManager.isEmpty {
            if let audio = getAudioFromDB(0) {
                audioManager.setCurrent(audio)
            }
        }
    }
    
    func getTotal() {
        let predicate = #Predicate<Audio> {
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
            if let item = getAudioFromDB(i) {
                Row(item)
            }
        }
    }
    
    func getAudioFromDB(_ i: Int) -> Audio? {
        // 创建一个 FetchDescriptor 查询特定行
        var descriptor = FetchDescriptor<Audio>()
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
