import Combine
import Foundation
import OSLog
import SwiftUI

extension MagicPlayMan {
    /// 播放事件发布者
    public class PlaybackEvents: ObservableObject {
        /// 事件订阅者信息
        public struct Subscriber {
            let id: UUID
            let name: String
            let date: Date
            let hasNavigationHandler: Bool

            public init(
                name: String,
                hasNavigationHandler: Bool = false
            ) {
                self.id = UUID()
                self.name = name
                self.date = Date()
                self.hasNavigationHandler = hasNavigationHandler
            }
        }

        @Published private(set) var subscribers: [Subscriber] = []

        public let onTrackFinished = PassthroughSubject<URL, Never>()
        public let onPlaybackFailed = PassthroughSubject<PlaybackState.PlaybackError, Never>()
        public let onBufferingStateChanged = PassthroughSubject<Bool, Never>()
        public let onStateChanged = PassthroughSubject<PlaybackState, Never>()
        public let onPreviousRequested = PassthroughSubject<URL, Never>()
        public let onNextRequested = PassthroughSubject<URL, Never>()
        public let onLikeStatusChanged = PassthroughSubject<(asset: URL, isLiked: Bool), Never>()
        public let onPlayModeChanged = PassthroughSubject<MagicPlayMode, Never>()
        public let onCurrentURLChanged = PassthroughSubject<URL, Never>()

        func addSubscriber(
            name: String,
            hasNavigationHandler: Bool = false
        ) -> UUID {
            let subscriber = Subscriber(
                name: name,
                hasNavigationHandler: hasNavigationHandler
            )
            subscribers.append(subscriber)
            return subscriber.id
        }

        func removeSubscriber(id: UUID) {
            subscribers.removeAll { $0.id == id }
        }

        func getSubscriberInfo(id: UUID) -> Subscriber? {
            subscribers.first { $0.id == id }
        }

        var hasNavigationSubscribers: Bool {
            subscribers.contains { $0.hasNavigationHandler }
        }

        init() {}
    }

    @discardableResult
    public func subscribe(
        name: String,
        onTrackFinished: ((URL) -> Void)? = nil,
        onPlaybackFailed: ((PlaybackState.PlaybackError) -> Void)? = nil,
        onBufferingStateChanged: ((Bool) -> Void)? = nil,
        onStateChanged: ((PlaybackState) -> Void)? = nil,
        onPreviousRequested: ((URL) -> Void)? = nil,
        onNextRequested: ((URL) -> Void)? = nil,
        onLikeStatusChanged: ((URL, Bool) -> Void)? = nil,
        onPlayModeChanged: ((MagicPlayMode) -> Void)? = nil,
        onCurrentURLChanged: ((URL) -> Void)? = nil
    ) -> UUID {
        let hasNavigationHandler = onPreviousRequested != nil || onNextRequested != nil
        let subscriberId = events.addSubscriber(
            name: name,
            hasNavigationHandler: hasNavigationHandler
        )

        if let handler = onTrackFinished {
            events.onTrackFinished
                .receive(on: DispatchQueue.main)
                .sink { [weak self] asset in
                    if self?.verbose == true {
                        os_log("\(self?.t ?? "")事件：单曲播放完成 - 将由 \(name) 处理")
                    }
                    handler(asset)
                }
                .store(in: &cancellables)
        }

        if let handler = onPlaybackFailed {
            events.onPlaybackFailed
                .receive(on: DispatchQueue.main)
                .sink { [weak self] error in
                    if self?.verbose == true {
                        os_log("\(self?.t ?? "")事件：播放失败 - 将由 \(name) 处理")
                    }
                    handler(error)
                }
                .store(in: &cancellables)
        }

        if let handler = onBufferingStateChanged {
            events.onBufferingStateChanged
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isBuffering in
                    if self?.verbose == true {
                        os_log("\(self?.t ?? "")事件：缓冲状态变化 - 将由 \(name) 处理")
                    }
                    handler(isBuffering)
                }
                .store(in: &cancellables)
        }

        if let handler = onStateChanged {
            events.onStateChanged
                .receive(on: DispatchQueue.main)
                .sink { [weak self] state in
                    if self?.verbose == true {
                        os_log("\(self?.t ?? "")事件：播放状态变化 - 将由 \(name) 处理")
                    }
                    handler(state)
                }
                .store(in: &cancellables)
        }

        if let handler = onPreviousRequested {
            events.onPreviousRequested
                .receive(on: DispatchQueue.main)
                .sink { [weak self] asset in
                    if self?.verbose == true {
                        os_log("\(self?.t ?? "")事件：请求上一首 - 将由 \(name) 处理")
                    }
                    handler(asset)
                }
                .store(in: &cancellables)
        }

        if let handler = onNextRequested {
            events.onNextRequested
                .receive(on: DispatchQueue.main)
                .sink { [weak self] asset in
                    if self?.verbose == true {
                        os_log("\(self?.t ?? "")🍋 事件：当前(\(asset.lastThreeComponents()))，请求下一首 - 将由 \(name) 处理")
                    }
                    handler(asset)
                }
                .store(in: &cancellables)
        }

        if let handler = onLikeStatusChanged {
            events.onLikeStatusChanged
                .receive(on: DispatchQueue.main)
                .sink { [weak self] event in
                    if self?.verbose == true {
                        os_log("\(self?.t ?? "")事件：喜欢状态变化 - 将由 \(name) 处理")
                    }
                    handler(event.asset, event.isLiked)
                }
                .store(in: &cancellables)
        }

        if let handler = onPlayModeChanged {
            events.onPlayModeChanged
                .receive(on: DispatchQueue.main)
                .sink { [weak self] mode in
                    if self?.verbose == true {
                        os_log("\(self?.t ?? "")事件：播放模式变化 - 将由 \(name) 处理")
                    }
                    handler(mode)
                }
                .store(in: &cancellables)
        }

        if let handler = onCurrentURLChanged {
            events.onCurrentURLChanged
                .receive(on: DispatchQueue.main)
                .sink { [weak self] url in
                    if self?.verbose == true {
                        os_log("\(self?.t ?? "")事件：当前 URL 变化 - 将由 \(name) 处理")
                    }
                    handler(url)
                }
                .store(in: &cancellables)
        }

        return subscriberId
    }

    public func unsubscribe(_ subscriberId: UUID) {
        if let subscriber = events.getSubscriberInfo(id: subscriberId) {
            events.removeSubscriber(id: subscriberId)
            if verbose {
                os_log("\(self.t)取消订阅：\(subscriber.name)")
            }
        }
    }
}

// MARK: - Preview

#Preview("MagicPlayMan") {
    MagicPlayMan.getPreviewView()
}
