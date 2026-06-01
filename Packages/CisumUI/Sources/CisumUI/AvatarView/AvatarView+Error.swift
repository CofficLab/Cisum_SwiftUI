import Foundation

extension AvatarView {
    /// 头像视图相关错误
    public enum ViewError: LocalizedError {
        case invalidURL
        case fileNotFound
        case thumbnailGenerationFailed(Error)
        case downloadFailed(Error?)

        public var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .fileNotFound:
                return "File does not exist"
            case .thumbnailGenerationFailed(let error):
                return "Could not generate thumbnail: \(error.localizedDescription)"
            case .downloadFailed(let error):
                if let error = error {
                    return "Download failed: \(error.localizedDescription)"
                } else {
                    return "Download failed"
                }
            }
        }

        public var underlyingError: Error? {
            switch self {
            case .invalidURL, .fileNotFound:
                return nil
            case .thumbnailGenerationFailed(let error):
                return error
            case .downloadFailed(let error):
                return error
            }
        }
    }
} 
