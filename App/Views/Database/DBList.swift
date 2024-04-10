import OSLog
import SwiftData
import SwiftUI

struct DBList: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Audio.order, animation: .default) var audios: [Audio]

    var total: Int { db.getTotal() }
    var db: DB { audioManager.db }
    var audio: Audio? { audioManager.audio }
    var showTips: Bool {
        if appManager.isDropping {
            return true
        }
        
        return appManager.flashMessage.isEmpty && total == 0
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                List {
                    Section(header: HStack {
                        Text("共 \(total.description)")
                        Spacer()
                        if UIConfig.isNotDesktop {
                            BtnAdd().labelStyle(.iconOnly)
                        }
                    }, content: {
                        ForEach(audios) { audio in
                            Row(audio)
                                .listRowInsets(EdgeInsets(top: 0, leading: -20, bottom: 0, trailing: -20))
                                .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: { indexSet in
                            for i in indexSet {
                                audioManager.dbFolder.trash(audios[i])
                            }
                        })
                    })
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
            
            if showTips {
                DBTips().shadow(radius: 8)
            }
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
