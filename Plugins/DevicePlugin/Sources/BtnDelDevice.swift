import SwiftUI
import CisumDeviceData

public struct BtnDelDevice: View {
    @Environment(\.modelContext) private var modelContext
    
    @State var hovered = false

    var deviceData: DeviceData
    var autoResize = false

    public init(deviceData: DeviceData, autoResize: Bool = false) {
        self.deviceData = deviceData
        self.autoResize = autoResize
    }

    public var body: some View {
//        ControlButton(
//            title: "删除设备",
//            image: getImageName(),
//            dynamicSize: autoResize,
//            onTap: {
////                Task {
////                    await DBSynced(Config.getSyncedContainer).deleteDevice(deviceData)
////                }
//            })
    }

    private func getImageName() -> String {
        return "trash"
    }
}
