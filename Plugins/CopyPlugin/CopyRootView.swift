@preconcurrency import AlertToast
@preconcurrency import MagicKit
@preconcurrency import MagicUI
@preconcurrency import OSLog
@preconcurrency import SwiftUI
@preconcurrency import UniformTypeIdentifiers

struct CopyRootView: View, SuperEvent, @preconcurrency SuperLog, SuperThread {
    static let emoji = "🚛"

    @EnvironmentObject var db: CopyDB
    @EnvironmentObject var s: StoreProvider
    @EnvironmentObject var m: MessageProvider
    @EnvironmentObject var p: PluginProvider
    @EnvironmentObject var worker: CopyWorker

    @State var isDropping: Bool = false
    @State var error: Error? = nil
    @State var iCloudAvailable = true
    @State var count: Int = 0

    init(verbose: Bool = false) {
        if verbose {
            os_log("\(Self.i)")
        }
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
        .onDrop(of: [UTType.fileURL], isTargeted: self.$isDropping) { providers in
            Task {
                await handleDrop(providers)
            }
            return true
        }
        .onReceive(NotificationCenter.default.publisher(for: .CopyFiles), perform: onCopyFiles)
    }

    @MainActor
    private func handleDrop(_ providers: [NSItemProvider]) async {
        let result = await onDrop(providers)
        if !result {
            os_log(.error, "\(self.t)Drop operation failed")
        }
    }
}

// MARK: Event Handler

extension CopyRootView {
    func onAppear() {
        let verbose = false

        if verbose {
            os_log("\(self.a)")
        }
    }

    func onCopyFiles(_ notification: Notification) {
        os_log("\(self.t)🍋🍋🍋 onCopyFiles")

        if let urls = notification.userInfo?["urls"] as? [URL],
           let folder = notification.userInfo?["folder"] as? URL {
            os_log("\(self.t)🍋🍋🍋 onCopyFiles, urls: \(urls.count), folder: \(folder.path)")
            self.worker.append(urls, folder: folder)
        }
    }

    func onDrop(_ providers: [NSItemProvider]) async -> Bool {
        let verbose = true

        if outOfLimit {
            return false
        }

        guard let disk = p.current?.getDisk() else {
            os_log(.error, "\(self.t)No Disk")
            await MainActor.run {
                self.m.toast("No Disk")
            }
            return false
        }

        let diskRoot = disk.root

        if verbose {
            os_log("\(self.t)开始处理拖放文件")
        }

        var urls: [URL] = []

        // Handle each provider separately and safely
        for provider in providers {
            if let itemProvider = try? await provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier) {
                if let urlData = itemProvider as? Data,
                   let url = URL(dataRepresentation: urlData, relativeTo: nil) {
                    urls.append(url)
                } else if let url = itemProvider as? URL {
                    urls.append(url)
                }
            }
        }

        if verbose {
            os_log("\(self.t)➕➕➕ 添加 \(urls.count) 个文件到复制队列")
        }

        await MainActor.run {
            self.worker.append(urls, folder: diskRoot)
        }

        return true
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
        .frame(width: 800)
}
