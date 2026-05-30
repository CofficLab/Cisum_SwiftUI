import CoreFoundation
import Foundation
import MagicPlayMan
import OSLog
import SwiftUI

public typealias AudioWidgetAdjacentAssetProvider = @MainActor (_ current: URL?, _ verbose: Bool) async throws -> URL?
public typealias AudioWidgetFirstAssetProvider = @MainActor () async throws -> URL?
public typealias AudioWidgetLastAssetProvider = @MainActor () async throws -> URL?

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
            .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
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
        let sharedDefaults = UserDefaults(suiteName: "group.com.yueyi.cisum")
        sharedDefaults?.synchronize()

        guard let sharedDefaults else { return }

        if sharedDefaults.object(forKey: "widgetPlayPauseTrigger") is TimeInterval {
            handlePlayPause()
            sharedDefaults.removeObject(forKey: "widgetPlayPauseTrigger")
        }

        if sharedDefaults.object(forKey: "widgetNextTrigger") is TimeInterval {
            handleNext()
            sharedDefaults.removeObject(forKey: "widgetNextTrigger")
        }

        if sharedDefaults.object(forKey: "widgetPreviousTrigger") is TimeInterval {
            handlePrevious()
            sharedDefaults.removeObject(forKey: "widgetPreviousTrigger")
        }
    }

    private func handlePlayPause() {
        if man.state == .playing {
            man.pause(reason: "Widget")
        } else {
            man.playCurrent(reason: "Widget")
        }
    }

    private func handleNext() {
        guard let asset = man.currentAsset else { return }

        Task { @MainActor in
            do {
                if let next = try await nextAsset(asset, Self.verbose) {
                    await man.play(next, autoPlay: true, reason: "Widget.Next")
                } else if man.playMode == .repeatAll, let first = try await firstAsset() {
                    await man.play(first, autoPlay: true, reason: "Widget.Loop")
                }
            } catch {
                Self.log.error("Failed to get next asset: \(error.localizedDescription)")
            }
        }
    }

    private func handlePrevious() {
        guard let asset = man.currentAsset else { return }

        Task { @MainActor in
            do {
                if let previous = try await previousAsset(asset, Self.verbose) {
                    await man.play(previous, autoPlay: true, reason: "Widget.Previous")
                } else if man.playMode == .repeatAll, let last = try await lastAsset() {
                    await man.play(last, autoPlay: true, reason: "Widget.RepeatAllPrevious")
                }
            } catch {
                Self.log.error("Failed to get previous asset: \(error.localizedDescription)")
            }
        }
    }
}

private extension Notification.Name {
    static let audioWidgetCommandReceived = Notification.Name("audioWidgetCommandReceived")
}
