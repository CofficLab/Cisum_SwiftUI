import Foundation
import MagicCore
import OSLog
import SwiftData
import SwiftUI

@MainActor
class MessageProvider: ObservableObject, SuperLog, SuperThread, SuperEvent {
    nonisolated static let emoji = "📪"
    
    let maxMessageCount = 100
    let logger = MagicLogger.shared

    @Published var alert: String?
    @Published var error: Error?
    @Published var toast: String?
    @Published var doneMessage: String?
    @Published var stateMessage: String = ""
    @Published var flashMessage: String = ""
    @Published var hub: String?

    @Published var showDone = false
    @Published var showError = false
    @Published var showToast = false
    @Published var showAlert = false
    @Published var showHub = false
    
    
    var showStateMessage: Bool { stateMessage.count > 0 }

    var showDoneMessage: Bool {
        doneMessage != nil
    }

    init() {
        let verbose = false
        if verbose {
            os_log("\(Self.i) MessageProvider")
        }
    }

    func alert(_ message: String) {
        if !Thread.isMainThread {
            assertionFailure("alert called from background thread")
        }

        self.alert = message
        self.showAlert = true
    }

    func append(_ message: String, channel: String = "default", isError: Bool = false) {
        if !Thread.isMainThread {
            assertionFailure("append called from background thread")
        }

        logger.info(message)
    }

    func done(_ message: String) {
        if !Thread.isMainThread {
            assertionFailure("done called from background thread")
        }

        self.doneMessage = message
        self.showDone = true
    }

    func clearAlert() {
        if !Thread.isMainThread {
            assertionFailure("clearAlert called from background thread")
        }

        self.alert = nil
        self.showAlert = false
    }

    func clearDoneMessage() {
        if !Thread.isMainThread {
            assertionFailure("clearDoneMessage called from background thread")
        }

        self.doneMessage = nil
        self.showDone = false
    }

    func clearError() {
        if !Thread.isMainThread {
            assertionFailure("clearError called from background thread")
        }

        self.error = nil
        self.showError = false
    }

    func clearToast() {
        if !Thread.isMainThread {
            assertionFailure("clearToast called from background thread")
        }

        self.toast = nil
        self.showToast = false
    }

    func clearMessages() {
        if !Thread.isMainThread {
            assertionFailure("clearMessages called from background thread")
        }

        self.logger.clearLogs()
    }

    func error(_ error: Error) {
        if !Thread.isMainThread {
            assertionFailure("error called from background thread")
        }

        self.error = error
        self.showError = true
    }
    
    func hub(_ title: String) {
        if !Thread.isMainThread {
            assertionFailure("toast called from background thread")
        }

        self.hub = title
        self.showHub = true
    }


    func toast(_ toast: String) {
        if !Thread.isMainThread {
            assertionFailure("toast called from background thread")
        }

        self.toast = toast
        self.showToast = true
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

