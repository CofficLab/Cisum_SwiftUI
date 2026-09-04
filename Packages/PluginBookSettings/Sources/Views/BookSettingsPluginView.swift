import CisumUIComponents
import PluginBook
import SwiftUI

struct BookSettingsPluginView: View {
    @ObservedObject private var viewModel: BookSettingsViewModel

    init(viewModel: BookSettingsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        BookSettingsView(refreshToken: viewModel.refreshToken) {
            BookPlugin.getBookDisk()
        }
    }
}
