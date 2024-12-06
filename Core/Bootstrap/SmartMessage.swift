import Foundation
import SwiftUI

struct SmartMessage: Hashable, Identifiable {
    var id: Date
    var duration: Int
    var shouldAlert: Bool = false
    var shouldFlash: Bool = false
    var description: String
    var createdAt: Date
    var channel: String = "default"
    var isError: Bool = false
    var isInfo: Bool = false
    init(
        duration: Int = 3,
        shouldAlert: Bool = false,
        description: String,
        channel: String = "default",
        isError: Bool = false
    ) {
        self.duration = duration
        self.shouldAlert = shouldAlert
        self.description = description
        self.id = Date()
        self.createdAt = Date()
        self.channel = channel
        self.isError = isError
    }
}
