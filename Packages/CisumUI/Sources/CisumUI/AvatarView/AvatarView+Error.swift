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
                return "无效的URL"
            case .fileNotFound:
                return "文件不存在"
            case .thumbnailGenerationFailed(let error):
                return "无法生成缩略图: \(error.localizedDescription)"
            case .downloadFailed(let error):
                if let error = error {
                    return "下载失败: \(error.localizedDescription)"
                } else {
                    return "下载失败"
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
