#if os(macOS)
import MagicAlert
import MagicCore
import MagicUI
import OSLog
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct CopyWorkerView: View, SuperEvent, SuperLog, SuperThread {
    nonisolated static var emoji: String { "🚛" }

    @EnvironmentObject var m: MagicMessageProvider
    @EnvironmentObject var p: PluginProvider
    @EnvironmentObject private var worker: CopyWorker

    @State var isDropping = false
    @State var error: Error? = nil
    @State var iCloudAvailable = true
    @State var count = 0

    private var verbose = false

    init() {
        if verbose {
            os_log("\(Self.i)")
        }
    }

    var outOfLimit: Bool {
        count >= Config.maxAudioCount && StoreService.tierCached().isFreeVersion
    }

    var showProTips: Bool {
        count >= Config.maxAudioCount && StoreService.tierCached().isFreeVersion && isDropping
    }

    var body: some View {
        VStack {
            if showProTips {
                ProTips()
            }

            if self.isDropping {
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

extension CopyWorkerView {
    func onAppear() {
        if self.verbose {
            os_log("\(self.a)")
        }
    }

    func onCopyFiles(_ notification: Notification) {
        if self.verbose {
            os_log("\(self.t)🍋🍋🍋 onCopyFiles")
        }

        guard let urls = notification.userInfo?["urls"] as? [URL],
              let folder = notification.userInfo?["folder"] as? URL else {
            return
        }

        os_log("\(self.t)🍋🍋🍋 onCopyFiles, urls: \(urls.count), folder: \(folder.path)")

        var tasks: [(bookmark: Data, filename: String)] = []
        for url in urls {
            do {
                let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                tasks.append((bookmark: bookmarkData, filename: url.lastPathComponent))
            } catch {
                os_log(.error, "\(self.t)Failed to create bookmark for url: \(url.path). Error: \(error.localizedDescription)")
            }
        }

        if !tasks.isEmpty {
            worker.append(tasks: tasks, folder: folder)
        }
    }

    func onDrop(_ providers: [NSItemProvider]) async -> Bool {
        if verbose {
            os_log("\(self.t)🚀 开始处理拖放文件")
        }

        if outOfLimit { return false }

        guard let disk = await MainActor.run(body: { p.current?.getDisk() }) else {
            os_log(.error, "\(self.t)No Disk")
            await MainActor.run { self.m.error("No Disk") }
            return false
        }

        var tasks: [(bookmark: Data, filename: String)] = []
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
                        // Create a security-scoped bookmark
                        let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                        tasks.append((bookmark: bookmarkData, filename: url.lastPathComponent))
                    }
                } catch {
                    os_log(.error, "\(self.t)Failed to load URL or create bookmark: \(error.localizedDescription)")
                }
            }
        }

        if verbose {
            os_log("\(self.t)🎁 获取到 \(tasks.count) 个文件")
        }

        if !tasks.isEmpty {
            await MainActor.run {
                self.m.info("\(tasks.count) 个文件开始复制")
                worker.append(tasks: tasks, folder: disk)
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
#endif
