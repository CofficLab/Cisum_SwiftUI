import SwiftUI
import SwiftData

struct StatusBarView: View {
    @EnvironmentObject var appManager: AppManager
    
    @Query var tasks: [CopyTask]
    
    var taskCount: Int { tasks.count }
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            Color.primary.opacity(0.9)
            
            HStack {
                Text(appManager.stateMessage).foregroundStyle(.white)
            }
            
            CopyTaskView()
        }
        .opacity(appManager.stateMessage.isEmpty && taskCount == 0 ? 0 : 1)
        .frame(height: 20)
    }
}

#Preview {
    RootView {
        VStack(alignment: .trailing, content: {
            Spacer()
            
            StatusBarView()
        }).background(Color.white).padding(30)
    }.modelContainer(AppConfig.getContainer())
}
