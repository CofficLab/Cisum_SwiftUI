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

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                List {
                    Section("共 \(total.description)", content: {
                        ForEach(audios) { audio in
                            Row(audio)
                                .listRowInsets(EdgeInsets(top: -0, leading: -20, bottom: 0, trailing: -20))
                                .listRowSeparator(.visible)
                        }
                    })
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
        }

        if audios.count == 0, appManager.flashMessage.isEmpty {
            DBEmptyView()
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
