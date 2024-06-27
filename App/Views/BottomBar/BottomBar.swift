import SwiftUI
import SwiftData

struct BottomBar: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var app: AppManager
    @Environment(\.modelContext) var context

    @Query(sort: \CopyTask.createdAt, animation: .default) var tasks: [CopyTask]
    
    var visible: Bool { tasks.count > 0 }
    
    var body: some View {
        ZStack {
            if visible {
                HStack(spacing: 0) {
                    // BottomViewType()
                    BottomCopyState()
                    
                    Spacer()
                }
                .frame(height: 25)
                .foregroundStyle(.white)
            } else {
                EmptyView()
            }
        }
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
