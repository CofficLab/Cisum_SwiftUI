import Foundation

public struct CisumToast: Sendable, Equatable {
    public let title: String
    public let detail: String?
    public let style: CisumToastStyle
    public let duration: TimeInterval?

    public init(
        title: String,
        detail: String? = nil,
        style: CisumToastStyle = .info,
        duration: TimeInterval? = nil
    ) {
        self.title = title
        self.detail = detail
        self.style = style
        self.duration = duration
    }
}

public struct CisumErrorNotice: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let title: String
    public let message: String

    public init(id: UUID = UUID(), title: String, message: String) {
        self.id = id
        self.title = title
        self.message = message
    }
}

public struct CisumLoadingNotice: Sendable, Equatable {
    public let title: String
    public let detail: String?

    public init(title: String, detail: String? = nil) {
        self.title = title
        self.detail = detail
    }
}

public enum CisumToastStyle: String, Sendable, Equatable {
    case info
    case success
    case warning
    case error
}
