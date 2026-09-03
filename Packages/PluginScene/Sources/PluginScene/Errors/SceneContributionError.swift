import Foundation

public enum SceneContributionError: LocalizedError {
    case unknownScene(String)

    public var errorDescription: String? {
        switch self {
        case let .unknownScene(sceneName):
            "Unknown scene: \(sceneName)"
        }
    }
}