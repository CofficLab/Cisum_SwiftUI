import AudioPlugin
import SwiftUI

public struct AudioDBDependencies: @unchecked Sendable {
    public var audioRepo: @MainActor @Sendable () -> AudioRepo?
    public var audioDisk: @MainActor @Sendable () -> URL?
    public var supportedExtensions: [String]
    public var isDesktop: Bool
    public var isNotDesktop: Bool
    public var showDBView: @MainActor @Sendable () -> Void
    public var isImporting: Binding<Bool>

    public init(
        audioRepo: @escaping @MainActor @Sendable () -> AudioRepo?,
        audioDisk: @escaping @MainActor @Sendable () -> URL?,
        supportedExtensions: [String],
        isDesktop: Bool,
        isNotDesktop: Bool,
        showDBView: @escaping @MainActor @Sendable () -> Void,
        isImporting: Binding<Bool>
    ) {
        self.audioRepo = audioRepo
        self.audioDisk = audioDisk
        self.supportedExtensions = supportedExtensions
        self.isDesktop = isDesktop
        self.isNotDesktop = isNotDesktop
        self.showDBView = showDBView
        self.isImporting = isImporting
    }

    public static let empty = AudioDBDependencies(
        audioRepo: { nil },
        audioDisk: { nil },
        supportedExtensions: [],
        isDesktop: true,
        isNotDesktop: false,
        showDBView: {},
        isImporting: .constant(false)
    )
}

private struct AudioDBDependenciesKey: EnvironmentKey {
    static let defaultValue = AudioDBDependencies.empty
}

public extension EnvironmentValues {
    var audioDBDependencies: AudioDBDependencies {
        get { self[AudioDBDependenciesKey.self] }
        set { self[AudioDBDependenciesKey.self] = newValue }
    }
}
