import SwiftUI

struct StatusView: View {
    @EnvironmentObject var databaseManager: DatabaseManager
    @EnvironmentObject var appManager: AppManager

    var body: some View {
        ZStack {
            Color.primary.opacity(0.2)

            HStack {
                if databaseManager.isCloudStorage {
                    Image(systemName: "icloud")
                        .onHover(perform: { hovering in
                            if hovering {
                                appManager.flashMessage = "当前已启用 iCloud"
                            } else {
                                appManager.flashMessage = ""
                            }
                        })
                } else {
                    Image(systemName: "folder.fill")
                        .onHover(perform: { hovering in
                            if hovering {
                                appManager.flashMessage = "当前数据仅存储在本地，未启用 iCloud"
                            } else {
                                appManager.flashMessage = ""
                            }
                        })
                }
            }
        }
    }
}

#Preview {
    RootView {
        NavigationSplitView(sidebar: {
            ZStack {
                Text("侧栏其他内容")

                VStack(alignment: .trailing) {
                    Spacer()
                    StatusView().frame(height: 50)
                }
            }
        }, detail: {
        })
    }
}
