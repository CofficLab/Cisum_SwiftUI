import OSLog
import SwiftUI

struct BootView<Content>: View, SuperEvent where Content: View {
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
                ProgressView()
            } else {
                Group {
                    if let e = self.error {
                        if e.isCloudError {
                            ErrorViewCloud(error: e)
                                .onChange(of: iCloudAvailable, onChangeOfiCloud)
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
                            .environmentObject(RootProvider())
                            .environmentObject(dataManager)
                            .environmentObject(DB(Config.getContainer, reason: "BootView"))
                            .environmentObject(DBSynced(Config.getSyncedContainer))
                        } else {
                            Text("启动失败")
                        }
                    }
                }
            }
        }
        .onReceive(nc.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification), perform: onCloudAccountStateChanged)
        .onAppear(perform: onAppear)
    }

    private func reloadView() {
        loading = true
        error = nil
        dataManager = nil
    }
}

// MARK: Event Handler

extension BootView {
    func onChangeOfiCloud() {
        if iCloudAvailable {
            reloadView()
        }
    }

    func onCloudAccountStateChanged(_ n: Notification) {
        let newAvailability = FileManager.default.ubiquityIdentityToken != nil
        if newAvailability != iCloudAvailable {
            iCloudAvailable = newAvailability
        }
    }

    func onAppear() {
        Task {
            do {
                try dataManager = await DataProvider()
            } catch let e {
                self.error = e
            }

            self.loading = false
        }
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
        .frame(width: 800)
}
