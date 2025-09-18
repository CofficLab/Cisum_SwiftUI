import MagicCore
import MagicUI
import MagicAlert
import OSLog
import SwiftUI
import UniformTypeIdentifiers

struct CopyRootView: View, SuperEvent, SuperLog, SuperThread {
    nonisolated static let emoji = "🚛"

    @EnvironmentObject var db: CopyDB
    @EnvironmentObject var s: StoreProvider
    @EnvironmentObject var m: MagicMessageProvider
    @EnvironmentObject var p: PluginProvider
    @EnvironmentObject var worker: CopyWorker

    @State var isDropping = false
    @State var error: Error? = nil
    @State var iCloudAvailable = true
    @State var count = 0

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
        let verbose = false
        if verbose {
            os_log("\(self.t)开始处理拖放文件")
        }

        if outOfLimit { return false }
        
        guard let disk = await MainActor.run(body: { p.current?.getDisk() }) else {
            os_log(.error, "\(self.t)No Disk")
            await MainActor.run { self.m.info("No Disk") }
            return false
        }

        var urls: [URL] = []
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                do {
                    let urlData: Data = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, Error>) in
                        provider.loadDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier) { data, error in
                            if let error = error {
                                continuation.resume(throwing: error)
                            } else if let data = data {
                                continuation.resume(returning: data)
                            } else {
                                continuation.resume(throwing: NSError(domain: "", code: -1))
                            }
                        }
                    }
                    if let url = URL(dataRepresentation: urlData, relativeTo: nil) {
                        urls.append(url)
                    }
                } catch {
                    os_log(.error, "\(self.t)Failed to load URL: \(error.localizedDescription)")
                }
            }
        }
        
        if verbose {
            os_log("\(self.t)获取到 \(urls.count) 个文件")
        }
        
        if !urls.isEmpty {
            await MainActor.run {
                self.m.info("\(urls.count) 个文件开始复制")
                self.worker.append(urls, folder: disk)
            }
        }

        return true
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
        .frame(width: 800)
}
