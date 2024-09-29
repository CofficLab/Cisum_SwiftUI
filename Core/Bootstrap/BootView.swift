import OSLog
import SwiftUI

struct BootView<Content>: View where Content: View {
    private var content: Content
    private var verbose = true
    private var label: String { "\(Logger.isMain)🌳 BootView::" }

    @State var dataManager: DataProvider?
    @State var error: Error? = nil
    @State var loading = true
    @State var iCloudAvailable = true

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        Group {
            if self.loading {
                loadingView
            } else {
                mainView
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification), perform: onCloudAccountStateChanged)
    }
    
    var loadingView: some View {
        ProgressView()
            .task {
                do {
                    try dataManager = await DataProvider()
                } catch let e {
                    self.error = e
                }
                
                self.loading = false
            }
    }
    
    var mainView: some View {
        Group {
            if let e = self.error {
                if let smartError = e as? DataProviderError, (smartError == DataProviderError.NoDisk || smartError == DataProviderError.iCloudAccountTemporarilyUnavailable) {
                    ErrorViewCloud(error: smartError)
                        .onChange(of: iCloudAvailable) {
                            if iCloudAvailable {
                                reloadView()
                            }
                        }
                } else {
                    ErrorViewFatal(error: e)
                }
            } else {
                if let dataManager = dataManager {
                    ZStack {
                        RootView()
                        content
                    }
                    .frame(minWidth: Config.minWidth, minHeight: Config.minHeight)
                    .blendMode(.normal)
                    .environmentObject(PlayMan())
                    .environmentObject(AppProvider())
                    .environmentObject(StoreProvider())
                    .environmentObject(PluginProvider())
                    .environmentObject(LayoutProvider())
                    .environmentObject(dataManager)
                    .environmentObject(DB(Config.getContainer, reason: "BootView"))
                    .environmentObject(DBSynced(Config.getSyncedContainer))
                } else {
                    Text("启动失败")
                }
            }
        }
    }

    private func reloadView() {
        loading = true
        error = nil
        dataManager = nil
    }
}

// MARK: Event Handler 

extension BootView {
    func onCloudAccountStateChanged(_ n: Notification) {
        let newAvailability = FileManager.default.ubiquityIdentityToken != nil
        if newAvailability != iCloudAvailable {
            iCloudAvailable = newAvailability
        }
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
