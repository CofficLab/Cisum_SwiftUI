#if os(macOS)
import MagicAlert
import MagicKit
import MagicUI
import OSLog
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct CopyRootView<Content>: View, SuperEvent, SuperLog, SuperThread where Content: View {
    nonisolated static var emoji: String { "🚛" }
    nonisolated static var verbose: Bool { false }

    @State var error: Error? = nil

    private var content: Content
    @State private var worker: CopyWorker?

    init(@ViewBuilder content: () -> Content) {
        if Self.verbose {
            os_log("\(Self.i)")
        }

        self.content = content()
    }

    var body: some View {
        if let worker = self.worker {
            ZStack {
                content
                CopyWorkerView()
            }
            .environmentObject(worker)
        } else {
            ProgressView()
                .onAppear {
                    do {
                        let container = try CopyConfig.getContainer()
                        let db = CopyDB(container, reason: "CopyRootView", verbose: false)
                        let worker = CopyWorker(db: db, reason: self.className)

                        self.worker = worker
                    } catch {
                        os_log(.error, "\(self.t)\(error)")
                        self.error = error
                    }
                }
        }
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
        .frame(width: 800)
}
#endif
