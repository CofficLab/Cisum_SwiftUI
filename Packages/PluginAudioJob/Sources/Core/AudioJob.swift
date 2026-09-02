import Foundation

public protocol AudioJob: Sendable {
    nonisolated var identifier: String { get }
    nonisolated var name: String { get }
    nonisolated var description: String { get }

    func execute() async throws
    func cancel()
}

public struct JobStatus: Sendable {
    public let identifier: String
    public let name: String
    public let isRunning: Bool

    public init(identifier: String, name: String, isRunning: Bool) {
        self.identifier = identifier
        self.name = name
        self.isRunning = isRunning
    }
}
