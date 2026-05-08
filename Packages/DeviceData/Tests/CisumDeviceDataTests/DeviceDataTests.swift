import Foundation
import Testing
@testable import CisumDeviceData

@Test
func initSetsUuidAndDefaults() {
    let item = DeviceData(uuid: "device-1")

    #expect(item.uuid == "device-1")
    #expect(item.firstOpenTime == .distantPast)
    #expect(item.lastOpenTime == .distantPast)
    #expect(item.timesOpened == 0)
    #expect(item.audioCount == 0)
    #expect(item.name.isEmpty)
    #expect(item.model.isEmpty)
    #expect(item.os.isEmpty)
    #expect(item.version.isEmpty)
}

@Test
func propertiesAreMutable() {
    let item = DeviceData(uuid: "device-2")
    let now = Date()

    item.firstOpenTime = now
    item.lastOpenTime = now
    item.timesOpened = 3
    item.audioCount = 42
    item.name = "MacBook Pro"
    item.model = "Mac16,5"
    item.os = "macOS"
    item.version = "15.0"

    #expect(item.firstOpenTime == now)
    #expect(item.lastOpenTime == now)
    #expect(item.timesOpened == 3)
    #expect(item.audioCount == 42)
    #expect(item.name == "MacBook Pro")
    #expect(item.model == "Mac16,5")
    #expect(item.os == "macOS")
    #expect(item.version == "15.0")
}
