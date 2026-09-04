import CisumUIComponents
import PluginAudio
import SwiftUI

struct AudioSettingsPluginView: View {
    @ObservedObject private var viewModel: AudioSettingsViewModel

    init(viewModel: AudioSettingsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        AudioSettingsView(refreshToken: viewModel.refreshToken) {
            AudioPlugin.getAudioDisk()
        }
    }
}
