import Foundation
import Combine
import MagicKit
import SwiftUI
import UniformTypeIdentifiers

#if os(macOS)
    import AppKit
    public typealias MagicPlatformImage = NSImage
#elseif os(iOS)
    import UIKit
    public typealias MagicPlatformImage = UIImage
#endif

public enum AvatarViewShape: Shape {
    case circle
    case rectangle
    case roundedRectangle(cornerRadius: CGFloat)
    case capsule

    public func path(in rect: CGRect) -> Path {
        switch self {
        case .circle:
            return Circle().path(in: rect)
        case .rectangle:
            return Rectangle().path(in: rect)
        case let .roundedRectangle(cornerRadius):
            return RoundedRectangle(cornerRadius: cornerRadius).path(in: rect)
        case .capsule:
            return Capsule().path(in: rect)
        }
    }
}

public extension URL {
    var isFileExist: Bool {
        isFileURL ? FileManager.default.fileExists(atPath: path) : true
    }

    var isNetworkURL: Bool {
        scheme == "http" || scheme == "https"
    }

    var isAudio: Bool {
        if let type = try? resourceValues(forKeys: [.contentTypeKey]).contentType {
            return type.conforms(to: .audio)
        }
        return ["mp3", "m4a", "aac", "wav", "aiff", "ogg", "opus", "flac", "alac"]
            .contains(pathExtension.lowercased())
    }

    var isVideo: Bool {
        if let type = try? resourceValues(forKeys: [.contentTypeKey]).contentType {
            return type.conforms(to: .movie) || type.conforms(to: .video)
        }
        return ["mp4", "m4v", "mov", "avi", "mkv", "webm", "mpeg", "mpg"]
            .contains(pathExtension.lowercased())
    }

    func makeAvatarView(verbose: Bool = false) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.quaternary)
            Image(systemName: isVideo ? "film" : isAudio ? "music.note" : "doc")
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .accessibilityLabel(title)
    }

    var systemIcon: String {
        if isVideo { return "film" }
        if isAudio { return "music.note" }
        return "doc"
    }

    func onDownloading(
        verbose: Bool = false,
        caller: String = "",
        onProgress: @escaping (Double) -> Void
    ) -> AnyCancellable {
        AnyCancellable {}
    }

    func onDownloadFinished(
        verbose: Bool = false,
        caller: String = "",
        onFinished: @escaping () -> Void
    ) -> AnyCancellable {
        AnyCancellable {}
    }

    func download(verbose: Bool = false, reason: String = "") async throws {}

    func thumbnail(
        size: CGSize,
        verbose: Bool = false,
        reason: String = ""
    ) async throws -> MagicThumbnailResult? {
        nil
    }

    func platformThumbnail(
        size: CGSize,
        verbose: Bool = false,
        reason: String = ""
    ) async throws -> MagicThumbnailResult? {
        try await thumbnail(size: size, verbose: verbose, reason: reason)
    }
}

public extension View {
    func magicSize(_ size: CGFloat) -> some View {
        frame(width: size, height: size)
    }

    func magicSize(_ size: CGSize) -> some View {
        frame(width: size.width, height: size.height)
    }

    func magicBackground(_ color: Color) -> some View {
        background(color)
    }

    func magicAvatarShape(_ shape: AvatarViewShape) -> some View {
        clipShape(shape)
    }

    func magicCentered() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    func infinite() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func shadowNone() -> some View {
        shadow(color: .clear, radius: 0)
    }

    func inButtonWithAction(_ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            self
        }
        .buttonStyle(.borderless)
    }

    func magicDownloadMonitor(_ isEnabled: Bool = true) -> some View {
        self
    }
}

public extension String {
    static let iconBackwardEndFill = "backward.end.fill"
    static let iconForwardEndFill = "forward.end.fill"
    static let iconGobackward10 = "gobackward.10"
    static let iconGoforward10 = "goforward.10"
    static let iconMusicNoteList = "music.note.list"
    static let iconPauseFill = "pause.fill"
    static let iconPersonGroup = "person.3"
    static let iconPersonGroupSlash = "person.3.sequence"
    static let iconPlay = "play"
    static let iconPlayFill = "play.fill"
    static let iconRepeat1 = "repeat.1"
    static let iconShuffle = "shuffle"
    static let iconRepeatAll = "repeat"
}

public extension LinearGradient {
    static var aurora: LinearGradient {
        LinearGradient(
            colors: [.green.opacity(0.35), .cyan.opacity(0.25), .purple.opacity(0.35)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var winter: LinearGradient {
        LinearGradient(
            colors: [.blue.opacity(0.16), .mint.opacity(0.12), .white.opacity(0.08)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

public struct MagicThumbnailResult {
    public let image: MagicPlatformImage?

    public init(image: MagicPlatformImage? = nil) {
        self.image = image
    }

    public func toSwiftUIImage() -> Image? {
        guard let image else { return nil }
        #if os(macOS)
            return Image(nsImage: image)
        #elseif os(iOS)
            return Image(uiImage: image)
        #else
            return nil
        #endif
    }
}

public struct MagicProgressBar: View {
    @Binding private var currentTime: TimeInterval
    private let duration: TimeInterval
    private let onSeek: (TimeInterval) -> Void

    public init(
        currentTime: Binding<TimeInterval>,
        duration: TimeInterval,
        onSeek: @escaping (TimeInterval) -> Void
    ) {
        self._currentTime = currentTime
        self.duration = duration
        self.onSeek = onSeek
    }

    public var body: some View {
        Slider(
            value: Binding(
                get: { currentTime },
                set: { value in
                    currentTime = value
                    onSeek(value)
                }
            ),
            in: 0...max(duration, 1)
        )
    }
}
