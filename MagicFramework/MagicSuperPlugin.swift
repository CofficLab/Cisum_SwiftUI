import SwiftUI

protocol MagicSuperPlugin: Actor {
    nonisolated var id: String { get }
    nonisolated var label: String { get }
    nonisolated var title: String { get }
    nonisolated var description: String { get }
    nonisolated var iconName: String { get }
    nonisolated var isGroup: Bool { get }

    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View
}

extension MagicSuperPlugin {
    nonisolated var id: String { self.label }
    nonisolated var label: String { String(describing: type(of: self)) }
    nonisolated var title: String { self.label }

    nonisolated var isGroup: Bool { false }

    nonisolated func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View { nil }
}

// MARK: - Convenience
extension MagicSuperPlugin {
    @MainActor
    func provideRootView(_ content: AnyView) -> AnyView? {
        self.addRootView { content }
    }

    @MainActor
    func wrapRoot(_ content: AnyView) -> AnyView {
        if let wrapped = self.provideRootView(content) {
            return wrapped
        }
        return content
    }
}


