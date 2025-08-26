import Foundation
import MagicCore
import OSLog
import SwiftData
import SwiftUI

@MainActor
class StateProvider: ObservableObject, SuperLog, SuperThread, SuperEvent {
    nonisolated static let emoji = "📪"
    
    let maxMessageCount = 100
    let logger = MagicLogger.shared

    @Published var stateMessage: String = ""
    
    var showStateMessage: Bool { stateMessage.count > 0 }

    init() {
        let verbose = false
        if verbose {
            os_log("\(Self.i) MessageProvider")
        }
    }

    func append(_ message: String, channel: String = "default", isError: Bool = false) {
        if !Thread.isMainThread {
            assertionFailure("append called from background thread")
        }

        logger.info(message)
    }

    func clearMessages() {
        if !Thread.isMainThread {
            assertionFailure("clearMessages called from background thread")
        }

        self.logger.clearLogs()
    }
}

// MARK: Event

extension Notification.Name {
    static let message = Notification.Name("message")
    static let messageError = Notification.Name("messageError")
    static let error = Notification.Name("error")
}

#Preview("Small Screen") {
    RootView {
        ContentView()
    }
    .frame(width: 500)
    .frame(height: 600)
}

#Preview("Big Screen") {
    RootView {
        ContentView()
    }
    .frame(width: 800)
    .frame(height: 1200)
}

