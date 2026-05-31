import CoreFoundation
import Foundation
import MagicPlayMan
import OSLog
import SwiftUI

public typealias AudioWidgetAdjacentAssetProvider = @MainActor (_ current: URL?, _ verbose: Bool) async throws -> URL?
public typealias AudioWidgetFirstAssetProvider = @MainActor () async throws -> URL?
public typealias AudioWidgetLastAssetProvider = @MainActor () async throws -> URL?

enum AudioWidgetPlaybackRequestPolicy {
    static func shouldApplyNavigationResult(requestedAsset: URL, currentAsset: URL?) -> Bool {
        currentAsset == requestedAsset
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
}

public struct AudioWidgetControlRootView: View {
    private static let verbose = false
    private static let log = Logger(subsystem: "com.yueyi.cisum", category: "AudioWidgetControl")
    private static var isWidgetCommandListenerRegistered = false

    @EnvironmentObject private var man: MagicPlayMan

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
        let sharedDefaults = UserDefaults(suiteName: "group.com.yueyi.cisum")

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
        let count = AudioWidgetPlaybackRequestPolicy.commandCount(
            from: sharedDefaults.object(forKey: key)
        )
        guard count > 0 else { return }

        handler(count)

        let remainingCount = AudioWidgetPlaybackRequestPolicy.remainingCommandCount(
            afterConsuming: count,
            storedValue: sharedDefaults.object(forKey: key)
        )
        if remainingCount > 0 {
            sharedDefaults.set(remainingCount, forKey: key)
        } else {
            sharedDefaults.removeObject(forKey: key)
        }
    }

    private func handlePlayPause(count: Int) {
        for _ in 0..<count {
            if man.state == .playing {
                man.pause(reason: "Widget")
            } else {
                man.playCurrent(reason: "Widget")
            }
        }
    }

    private func handleNext(count: Int) {
        Task { @MainActor in
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
        Task { @MainActor in
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
}

private extension Notification.Name {
    static let audioWidgetCommandReceived = Notification.Name("audioWidgetCommandReceived")
}
