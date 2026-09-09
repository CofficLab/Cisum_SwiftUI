import Foundation
import CisumUIComponents
import ProviderBook
import SwiftData
import SwiftUI

public struct BookRootView<Content>: View, SuperLog where Content: View {
    public nonisolated static var emoji: String { "🏓" }
    public nonisolated static var verbose: Bool { false }

    @ObservedObject private var viewModel: BookRootViewModel
    private var content: Content

    init(viewModel: BookRootViewModel, @ViewBuilder content: () -> Content) {
        self.viewModel = viewModel
        self.content = content()
    }

    public var body: some View {
        Group {
            if let error = viewModel.error {
                error.makeView()
            } else if viewModel.isLoading {
                ProgressView {
                    Text("Initializing...", bundle: .module)
                }
            } else if let container = viewModel.container, let repo = viewModel.repo {
                ZStack {
                    content
                }
                .modelContainer(container)
                .environmentObject(repo)
            } else {
                Text("Initialization Failed", bundle: .module)
            }
        }
        .onAppear {
            viewModel.reloadContainer()
        }
    }
}
