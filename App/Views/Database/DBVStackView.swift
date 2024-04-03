import SwiftUI
import SwiftData
import OSLog

struct DBVStackView: View {
    @EnvironmentObject var audioManager: AudioManager
    @Environment(\.modelContext) private var modelContext
    
    var total: Int {
        let predicate = #Predicate<PlayItem> {
            $0.order != -1
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        do {
            let result = try modelContext.fetchCount(descriptor)
            return result
        } catch {
            return 0
        }
    }

    var body: some View {
        lazy.onAppear {
            if total > 0 && audioManager.isEmpty {
                if let audio = getItemFromDB(0) {
                    audioManager.setCurrent(audio)
                }
            }
        }
    }

    var lazy: some View {
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
        }
    }
    
    func makeRow(_ i: Int) -> some View {
        os_log("🖥️ 渲染 \(i)")
        return ZStack {
            if let item = getItemFromDB(i) {
                Cell(Audio(item.url))
            } else {
                Text("\(i)")
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

#Preview {
    RootView {
        DBListView()
    }
}
