import SwiftUI

struct BtnDelDevice: View {
    @EnvironmentObject var audioManager: PlayManager
    @State var hovered = false
    @Environment(\.modelContext) private var modelContext

    var deviceData: DeviceData
    var autoResize = false

    var body: some View {
        ControlButton(
            title: "删除设备",
            image: getImageName(),
            dynamicSize: autoResize,
            onTap: {
                Task {
                    await DBSynced(AppConfig.getSyncedContainer).deleteDevice(deviceData)
                }
            })
    }

    private func getImageName() -> String {
        return "trash"
    }
}

#Preview("Layout") {
    LayoutView()
}
