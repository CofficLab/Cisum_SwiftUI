import AlertToast
import MagicKit
import OSLog
import SwiftUI
import UniformTypeIdentifiers

struct CopyRootView: View, SuperEvent, SuperLog, SuperThread {
    static var emoji = "🚛"

    @EnvironmentObject var db: CopyDB
    @EnvironmentObject var s: StoreProvider
    @EnvironmentObject var m: MessageProvider
    @EnvironmentObject var p: PluginProvider
    @EnvironmentObject var worker: CopyWorker

    @State var dataManager: DataProvider?
    @State var isDropping: Bool = false
    @State var error: Error? = nil
    @State var iCloudAvailable = true
    @State var count: Int = 0

    init() {
        // os_log("\(Self.i)")
    }

    var outOfLimit: Bool {
        count >= Config.maxAudioCount && s.currentSubscription == nil
    }

    var showDropTips: Bool {
        return isDropping
    }

    var showProTips: Bool {
        count >= Config.maxAudioCount && s.currentSubscription == nil && isDropping
    }

    var body: some View {
        VStack {
            if showProTips {
                ProTips()
            }

            if showDropTips {
                DropTips()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .onAppear(perform: onAppear)
        .onDrop(of: [UTType.fileURL], isTargeted: self.$isDropping, perform: onDrop)
    }
}

// MARK: Event Handler

extension CopyRootView {
    func onAppear() {
        os_log("\(self.a)")
    }

    func onDrop(_ providers: [NSItemProvider]) -> Bool {
        let verbose = true
        
        if outOfLimit {
            return false
        }

        // Extract URLs from providers on the main thread
        let urls = providers.compactMap { provider -> URL? in
            var result: URL?
            let semaphore = DispatchSemaphore(value: 0)

            _ = provider.loadObject(ofClass: URL.self) { url, _ in
                result = url
                semaphore.signal()
            }

            semaphore.wait()
            return result
        }

        if verbose {
            os_log("\(self.t)添加 \(urls.count) 个文件到复制队列")
        }
        
        self.emitCopyFiles(urls)

        guard let disk = p.current?.getDisk() else {
            os_log(.error, "\(self.t)No Disk")
            self.m.toast("No Disk")
            return false
        }

        if verbose {
            self.m.toast("复制 \(urls.count) 个文件")
        }

        self.worker.append(urls, folder: disk.root)

        return true
    }
}

// MARK: Event Emit

extension CopyRootView {
    func emitCopyFiles(_ urls: [URL]) {
        self.main.async {
            NotificationCenter.default.post(name: .CopyFiles, object: self, userInfo: ["urls": urls])
        }
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
        .frame(width: 800)
}
