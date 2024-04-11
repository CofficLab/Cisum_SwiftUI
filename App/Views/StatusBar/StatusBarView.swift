import SwiftUI
import SwiftData

struct StatusBarView: View {
    @EnvironmentObject var appManager: AppManager
    
    @Query var tasks: [CopyTask]
    
    var taskCount: Int { tasks.count }
    var showStateMessage: Bool { appManager.stateMessage.count > 0 }
    var showCopyMessage: Bool { tasks.count > 0 }
    
    var body: some View {
        VStack {
            if showStateMessage {
                HStack {
                    Text(appManager.stateMessage)
                }.frame(height: 20)
            }
            
            if showStateMessage && showCopyMessage {
                Divider()
            }
            
            if showCopyMessage {
                VStack(spacing: 0) {
                    Spacer()
                    CopyTaskView()
                    Spacer()
                }
                .frame(height: 20)
            }
        }
        .frame(maxWidth: .infinity)
        .background(ZStack {
            AppConfig.getBackground
            BackgroundView()
        })
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}

#Preview {
    RootView {
        VStack(alignment: .trailing, content: {
            Spacer()
            
            StatusBarView()
        }).background(.background).padding(30)
    }.modelContainer(AppConfig.getContainer())
}
