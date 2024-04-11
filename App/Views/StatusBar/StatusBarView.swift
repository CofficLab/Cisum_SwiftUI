import SwiftUI

struct StatusBarView: View {
    @EnvironmentObject var appManager: AppManager
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            Color.primary.opacity(0.9)
            
            HStack {
                Text(appManager.stateMessage).foregroundStyle(.white)
            }
            
            CopyTaskView()
        }
//        .opacity(appManager.stateMessage.isEmpty ? 0 : 1)
        .frame(height: 20)
    }
}

#Preview {
    RootView {
        VStack(alignment: .trailing, content: {
            Spacer()
            
            StatusBarView()
        }).background(Color.white).padding(30)
    }
}
