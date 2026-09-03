import CoreFoundation
import Darwin
import Foundation
import CisumUIComponents
import MagicPlayMan
import OSLog
import SwiftUI

public typealias AudioWidgetAdjacentAssetProvider = @MainActor (_ current: URL?, _ verbose: Bool) async throws -> URL?
public typealias AudioWidgetFirstAssetProvider = @MainActor () async throws -> URL?
public typealias AudioWidgetLastAssetProvider = @MainActor () async throws -> URL?

enum AudioWidgetPlayPauseAction {
    case play
    case pause
}

enum AudioWidgetPlaybackRequestPolicy {
    static func shouldApplyNavigationResult(requestedAsset: URL, currentAsset: URL?) -> Bool {
        representsSameFile(requestedAsset, currentAsset)
    }

    static func shouldWaitForPreviousNavigation(hasPreviousTask: Bool) -> Bool {
        hasPreviousTask
    }

    static func commandCount(from storedValue: Any?, maximum: Int = 10) -> Int {
        if let number = storedValue as? NSNumber {
            let doubleValue = number.doubleValue
            guard doubleValue.isFinite else { return 0 }

            if doubleValue > 1_000_000 {
                return 1
            }

            return min(max(Int(doubleValue), 0), maximum)
        }

        if let count = storedValue as? Int {
            return min(max(count, 0), maximum)
        }

        if let timestamp = storedValue as? TimeInterval, timestamp.isFinite {
            return 1
        }

        return 0
    }

    static func remainingCommandCount(afterConsuming consumedCount: Int, storedValue: Any?) -> Int {
        max(0, commandCount(from: storedValue, maximum: 1_000_000) - consumedCount)
    }

    static func playPauseAction(currentState: PlaybackState, commandCount: Int) -> AudioWidgetPlayPauseAction? {
        guard commandCount > 0, commandCount.isMultiple(of: 2) == false else {
            return nil
        }

        return currentState == .playing ? .pause : .play
    }

    private static func representsSameFile(_ lhs: URL?, _ rhs: URL?) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case let (.some(lhs), .some(rhs)):
            return lhs.isSameFileLocation(as: rhs)
        default:
            return false
        }
    }
}

private enum AudioWidgetCommandStore {
    static let suiteName = "group.com.yueyi.cisum"

    static func withLock<T>(_ operation: () throws -> T) rethrows -> T {
        guard let lockURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: suiteName)?
            .appendingPathComponent("widget-command.lock") else {
            return try operation()
        }

        FileManager.default.createFile(atPath: lockURL.path, contents: nil)
        guard let handle = try? FileHandle(forWritingTo: lockURL) else {
            return try operation()
        }

        flock(handle.fileDescriptor, LOCK_EX)
        defer {
            flock(handle.fileDescriptor, LOCK_UN)
            try? handle.close()
        }

        return try operation()
    }
}

public struct AudioWidgetControlRootView: View {
    private static let verbose = false
    private static let log = Logger(subsystem: "com.yueyi.cisum", category: "AudioWidgetControl")
    private static var isWidgetCommandListenerRegistered = false

    @EnvironmentObject private var man: MagicPlayMan
    @State private var navigationTask: Task<Void, Never>?

    private let nextAsset: AudioWidgetAdjacentAssetProvider
    private let previousAsset: AudioWidgetAdjacentAssetProvider
    private let firstAsset: AudioWidgetFirstAssetProvider
    private let lastAsset: AudioWidgetLastAssetProvider

    public init(
        nextAsset: @escaping AudioWidgetAdjacentAssetProvider,
        previousAsset: @escaping AudioWidgetAdjacentAssetProvider,
        firstAsset: @escaping AudioWidgetFirstAssetProvider,
        lastAsset: @escaping AudioWidgetLastAssetProvider
    ) {
        self.nextAsset = nextAsset
        self.previousAsset = previousAsset
        self.firstAsset = firstAsset
        self.lastAsset = lastAsset
    }

    public var body: some View {
        EmptyView()
            .onAppear {
                setupWidgetCommandListener()
                handleWidgetCommands()
            }
            .onReceive(NotificationCenter.default.publisher(for: .audioWidgetCommandReceived)) { _ in
                handleWidgetCommands()
            }
    }

    private func setupWidgetCommandListener() {
        guard !Self.isWidgetCommandListenerRegistered else { return }
        Self.isWidgetCommandListenerRegistered = true

        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let callback: CFNotificationCallback = { _, _, _, _, _ in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .audioWidgetCommandReceived, object: nil)
            }
        }

        CFNotificationCenterAddObserver(center, nil, callback, "com.yueyi.cisum.widgetCommand" as CFString, nil, .deliverImmediately)

        if Self.verbose {
            Self.log.debug("Registered widget command listener")
        }
    }

    private func handleWidgetCommands() {
        let sharedDefaults = UserDefaults(suiteName: AudioWidgetCommandStore.suiteName)

        guard let sharedDefaults else { return }

        consumeWidgetCommand(key: "widgetPlayPauseTrigger", from: sharedDefaults, handler: handlePlayPause)
        consumeWidgetCommand(key: "widgetNextTrigger", from: sharedDefaults, handler: handleNext)
        consumeWidgetCommand(key: "widgetPreviousTrigger", from: sharedDefaults, handler: handlePrevious)
    }

    private func consumeWidgetCommand(
        key: String,
        from sharedDefaults: UserDefaults,
        handler: (Int) -> Void
    ) {
        let count = AudioWidgetCommandStore.withLock {
            AudioWidgetPlaybackRequestPolicy.commandCount(
                from: sharedDefaults.object(forKey: key)
            )
        }
        guard count > 0 else { return }

        handler(count)

        AudioWidgetCommandStore.withLock {
            let remainingCount = AudioWidgetPlaybackRequestPolicy.remainingCommandCount(
                afterConsuming: count,
                storedValue: sharedDefaults.object(forKey: key)
            )
            if remainingCount > 0 {
                sharedDefaults.set(remainingCount, forKey: key)
            } else {
                sharedDefaults.removeObject(forKey: key)
            }
            sharedDefaults.synchronize()
        }
    }

    private func handlePlayPause(count: Int) {
        switch AudioWidgetPlaybackRequestPolicy.playPauseAction(
            currentState: man.state,
            commandCount: count
        ) {
        case .play:
            man.playCurrent(reason: "Widget")
        case .pause:
            man.pause(reason: "Widget")
        case .none:
            break
        }
    }

    private func handleNext(count: Int) {
        enqueueNavigationTask {
            for _ in 0..<count {
                guard let asset = man.currentAsset else { return }

                do {
                    if let next = try await nextAsset(asset, Self.verbose) {
                        guard AudioWidgetPlaybackRequestPolicy.shouldApplyNavigationResult(
                            requestedAsset: asset,
                            currentAsset: man.currentAsset
                        ) else {
                            return
                        }
                        await man.play(next, autoPlay: true, reason: "Widget.Next")
                    } else if man.playMode == .repeatAll, let first = try await firstAsset() {
                        guard AudioWidgetPlaybackRequestPolicy.shouldApplyNavigationResult(
                            requestedAsset: asset,
                            currentAsset: man.currentAsset
                        ) else {
                            return
                        }
                        await man.play(first, autoPlay: true, reason: "Widget.Loop")
                    }
                } catch {
                    Self.log.error("Failed to get next asset: \(error.localizedDescription)")
                    return
                }
            }
        }
    }

    private func handlePrevious(count: Int) {
        enqueueNavigationTask {
            for _ in 0..<count {
                guard let asset = man.currentAsset else { return }

                do {
                    if let previous = try await previousAsset(asset, Self.verbose) {
                        guard AudioWidgetPlaybackRequestPolicy.shouldApplyNavigationResult(
                            requestedAsset: asset,
                            currentAsset: man.currentAsset
                        ) else {
                            return
                        }
                        await man.play(previous, autoPlay: true, reason: "Widget.Previous")
                    } else if man.playMode == .repeatAll, let last = try await lastAsset() {
                        guard AudioWidgetPlaybackRequestPolicy.shouldApplyNavigationResult(
                            requestedAsset: asset,
                            currentAsset: man.currentAsset
                        ) else {
                            return
                        }
                        await man.play(last, autoPlay: true, reason: "Widget.RepeatAllPrevious")
                    }
                } catch {
                    Self.log.error("Failed to get previous asset: \(error.localizedDescription)")
                    return
                }
            }
        }
    }

    private func enqueueNavigationTask(_ operation: @escaping @MainActor () async -> Void) {
        let previousTask = navigationTask
        navigationTask = Task { @MainActor in
            if AudioWidgetPlaybackRequestPolicy.shouldWaitForPreviousNavigation(hasPreviousTask: previousTask != nil) {
                await previousTask?.value
            }
            await operation()
        }
    }
}

private extension Notification.Name {
    static let audioWidgetCommandReceived = Notification.Name("audioWidgetCommandReceived")
}
