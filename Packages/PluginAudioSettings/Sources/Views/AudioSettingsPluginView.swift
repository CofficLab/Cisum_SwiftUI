import CisumUIComponents
import AudioLibraryCore
import SwiftUI

struct AudioSettingsPluginView: View {
    @ObservedObject private var viewModel: AudioSettingsViewModel

    init(viewModel: AudioSettingsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        AudioSettingsView(refreshToken: viewModel.refreshToken) {
            AudioPluginHost.getAudioDisk()
        }
    }
}
