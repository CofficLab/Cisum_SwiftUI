import AlertToast
import OSLog
import SwiftUI
import MagicKit

struct BootView<Content>: View, SuperEvent, SuperLog where Content: View {
    var content: Content
    let emoji = "🌳"
    let a = AppProvider()
    let p = PluginProvider()
    let s = StoreProvider()
    let f = FamalyProvider()
    let man = PlayMan()
    let db = DB(Config.getContainer, reason: "BootView")
    let dbSyncedd = DBSynced(Config.getSyncedContainer)
    
    @State var dataManager: DataProvider?
    @State var error: Error? = nil
    @State var loading = true
    @State var iCloudAvailable = true

    @StateObject var m = MessageProvider()

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
                            .environmentObject(man)
                            .environmentObject(a)
                            .environmentObject(s)
                            .environmentObject(p)
                            .environmentObject(f)
                            .environmentObject(dataManager)
                            .environmentObject(db)
                            .environmentObject(dbSyncedd)
                            .environmentObject(m)
                        } else {
                            Text("启动失败")
                        }
                    }
                }
            }
        }
        .toast(isPresenting: $m.showToast, alert: {
            AlertToast(type: .systemImage("info.circle", .blue), title: m.toast)
        }, completion: {
            m.clearToast()
        })
        .toast(isPresenting: $m.showAlert, alert: {
            AlertToast(displayMode: .alert, type: .error(.red), title: m.alert)
        }, completion: {
            m.clearAlert()
        })
        .toast(isPresenting: $m.showDone, alert: {
            AlertToast(type: .complete(.green), title: m.doneMessage)
        }, completion: {
            m.clearDoneMessage()
        })
        .toast(isPresenting: $m.showError, duration: 0, tapToDismiss: true, alert: {
            AlertToast(displayMode: .alert, type: .error(.indigo), title: m.error?.localizedDescription)
        }, completion: {
            m.clearError()
        })
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
                try dataManager = await DataProvider(verbose: true)
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
