import SwiftUI

struct ButtonPlayList: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var databaseManager: DBManager
//    @EnvironmentObject var playListManager: PlayListManager

    @State private var selectedList: String = ""
    @State private var popoverDisplay: Bool = false

    var body: some View {
        HStack {
//            Text(playListManager.current.title)
//                .font(.title2)
//                .foregroundStyle(.white)
//                .onTapGesture {
//                    popoverDisplay.toggle()
//                }
        }
//        .popover(isPresented: $popoverDisplay, arrowEdge: .bottom) {
//            List {
//                ForEach(playListManager.items) { item in
//                    Text(item.title)
//                }
//            }
//        }

    }
}

#Preview {
    RootView(content: {
        Centered {
            ButtonPlayList()
        }
    })
}
