import SwiftUI

// MARK: - CoverArtModifier

/// 封面设置视图修饰器
///
/// 为视图添加设置封面功能，包括右键菜单和图片选择器。
/// 使用 `CoverArtViewModel` 处理业务逻辑。
public struct CoverArtModifier: ViewModifier {
    // MARK: - Properties

    /// 目标文件 URL
    let targetURL: URL

    /// 是否启用详细日志
    let verbose: Bool

    /// 封面设置完成后的回调
    let onCompletion: (() -> Void)?

    /// 封面设置失败后的回调
    let onError: ((Error) -> Void)?

    /// 视图模型
    @StateObject private var viewModel: CoverArtViewModel

    // MARK: - Initialization

    /// 创建封面设置修饰器
    /// - Parameters:
    ///   - targetURL: 要设置封面的目标文件 URL
    ///   - verbose: 是否启用详细日志，默认为 false
    ///   - onCompletion: 完成回调
    ///   - onError: 错误回调
    public init(
        targetURL: URL,
        verbose: Bool = false,
        onCompletion: (() -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        self.targetURL = targetURL
        self.verbose = verbose
        self.onCompletion = onCompletion
        self.onError = onError
        self._viewModel = StateObject(wrappedValue: CoverArtViewModel(
            targetURL: targetURL,
            verbose: verbose
        ))
    }

    // MARK: - Body

    public func body(content: Content) -> some View {
        content
            .contextMenu {
                // 仅对本地文件显示设置封面选项
                if targetURL.isFileURL {
                    Button {
                        viewModel.selectImage()
                    } label: {
                        Label("设置封面", systemImage: "photo")
                    }

                    Divider()
                }
            }
            .fileImporter(
                isPresented: $viewModel.isImagePickerPresented,
                allowedContentTypes: [.image],
                allowsMultipleSelection: false
            ) { result in
                handleImageSelection(result)
            }
    }

    // MARK: - Private Methods

    /// 处理图片选择结果
    /// - Parameter result: 文件选择器结果
    private func handleImageSelection(_ result: Result<[URL], Error>) {
        viewModel.onCompletion = {
            // 通知完成
            onCompletion?()
        }

        viewModel.onError = { error in
            // 通知错误
            onError?(error)
        }

        viewModel.handleImageSelection(result: result)
    }
}

// MARK: - AvatarView Extension

extension AvatarView {
    /// 为头像视图添加设置封面功能
    /// - Parameters:
    ///   - verbose: 是否启用详细日志
    ///   - onCompletion: 封面设置完成后的回调
    ///   - onError: 封面设置失败后的回调
    /// - Returns: 应用了封面设置修饰器的视图
    public func coverArtSettings(
        verbose: Bool = false,
        onCompletion: (() -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) -> some View {
        self.modifier(CoverArtModifier(
            targetURL: url,
            verbose: verbose,
            onCompletion: {
                // 完成后重新加载缩略图
                state.reset()
                onCompletion?()
            },
            onError: { error in
                // 设置错误状态
                state.setError(ViewError.thumbnailGenerationFailed(error))
                onError?(error)
            }
        ))
    }
}

// MARK: - View Extension (便捷方法)

public extension View {
    /// 为任何视图添加封面设置功能
    /// - Parameters:
    ///   - targetURL: 要设置封面的目标文件 URL
    ///   - onReload: 封面设置成功后重新加载内容的回调
    ///   - verbose: 是否启用详细日志
    ///   - onCompletion: 完成回调
    ///   - onError: 错误回调
    /// - Returns: 应用了封面设置修饰器的视图
    func magicCoverArt(
        for targetURL: URL,
        onReload: (() -> Void)? = nil,
        verbose: Bool = false,
        onCompletion: (() -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) -> some View {
        self.modifier(CoverArtModifier(
            targetURL: targetURL,
            verbose: verbose,
            onCompletion: {
                // 重新加载内容
                onReload?()
                onCompletion?()
            },
            onError: onError
        ))
    }
}

// MARK: - Preview

#if DEBUG
    #Preview("封面设置功能") {
        VStack(spacing: 20) {
            Text("右键点击下方头像查看'设置封面'选项")
                .font(.caption)
                .foregroundStyle(.secondary)

            // 使用示例
            if let url = URL(string: "file:///tmp/test.mp3") {
                AvatarView(url: url)
                    .coverArtSettings(verbose: true)
            }
        }
        .frame(width: 300, height: 200)
    }
#endif
