import Foundation
import MagicKit
import OSLog
import SwiftData

public enum AudioLikeRepoError: Error, LocalizedError {
    case containerNotAvailable
    case databaseURLNotConfigured

    public var errorDescription: String? {
        switch self {
        case .containerNotAvailable:
            return "数据容器不可用"
        case .databaseURLNotConfigured:
            return "AudioLike 数据库路径未配置"
        }
    }
}

@MainActor
public enum AudioLikeRepositoryConfiguration {
    private static var databaseURL: URL?

    public static func configure(databaseURL: URL) {
        let shouldResetContainer = Self.databaseURL != databaseURL
        Self.databaseURL = databaseURL

        if shouldResetContainer {
            AudioLikeRepo.shared.resetContainerForConfigurationChange()
        }
    }

    static func currentDatabaseURL() -> URL? {
        databaseURL
    }
}

public actor AudioLikeRepo: SuperLog {
    public static let emoji = "💖"
    public static let verbose = false

    public static let shared = AudioLikeRepo()

    @MainActor
    private var container: ModelContainer?

    private init() {}

    @MainActor
    fileprivate func resetContainerForConfigurationChange() {
        container = nil
    }

    @MainActor
    private var context: ModelContext? {
        get async throws {
            try await ensureContainer()
            return container?.mainContext
        }
    }

    @MainActor
    private func ensureContainer() async throws {
        guard container == nil else { return }
        guard let databaseURL = AudioLikeRepositoryConfiguration.currentDatabaseURL() else {
            throw AudioLikeRepoError.databaseURLNotConfigured
        }

        let schema = Schema([AudioLikeModel.self])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            url: databaseURL,
            allowsSave: true,
            cloudKitDatabase: .none
        )
        container = try ModelContainer(for: schema, configurations: [modelConfiguration])
    }

    @MainActor
    public func isLiked(audioId: String) async -> Bool {
        do {
            guard let context = try await self.context else { return false }
            let descriptor = AudioLikeModel.descriptorOf(audioId: audioId)
            let results = try context.fetch(descriptor)
            return results.first?.liked ?? false
        } catch {
            os_log(.error, "\(self.t)❌ 检查喜欢状态失败: \(error.localizedDescription)")
            return false
        }
    }

    public func isLiked(url: URL) async -> Bool {
        let audioId = url.absoluteString
        return await isLiked(audioId: audioId)
    }

    @MainActor
    public func findLikeModel(audioId: String) async throws -> AudioLikeModel? {
        guard let context = try await self.context else { return nil }

        let descriptor = AudioLikeModel.descriptorOf(audioId: audioId)
        let results = try context.fetch(descriptor)
        return results.first
    }

    @MainActor
    public func save(_ model: AudioLikeModel) async throws {
        guard let context = try await self.context else {
            throw AudioLikeRepoError.containerNotAvailable
        }

        if model.modelContext == nil {
            context.insert(model)
        }
        try context.save()
    }

    public func updateLikeStatus(audioId: String, liked: Bool, url: URL? = nil, title: String? = nil) async throws {
        try await AudioLikeRepo.performOnMainActor {
            if let existingModel = try await self.findLikeModel(audioId: audioId) {
                if !liked {
                    try await self.removeLikeStatus(audioId: audioId)
                    return
                }

                existingModel.liked = liked
                if let url {
                    existingModel.url = url
                }
                if let title {
                    existingModel.title = title
                }
                existingModel.updatedAt = Date()
                try await self.save(existingModel)
            } else {
                guard liked else { return }

                let newModel = AudioLikeModel(audioId: audioId, url: url, title: title, liked: liked)
                try await self.save(newModel)
            }
        }
    }

    @MainActor
    private static func performOnMainActor<T>(_ operation: @MainActor () async throws -> T) async throws -> T {
        try await operation()
    }

    @MainActor
    public func getAllLiked() async -> [AudioLikeModel] {
        do {
            guard let context = try await self.context else { return [] }
            let results = try context.fetch(AudioLikeModel.descriptorLiked)
            return results
        } catch {
            os_log(.error, "\(self.t)❌ 获取喜欢列表失败: \(error.localizedDescription)")
            return []
        }
    }

    @MainActor
    public func removeLikeStatus(audioId: String) async throws {
        guard let context = try await self.context else { return }

        if let model = try await findLikeModel(audioId: audioId) {
            context.delete(model)
            try context.save()
        }
    }
}
