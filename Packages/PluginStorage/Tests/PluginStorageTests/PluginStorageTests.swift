import Testing
@testable import PluginStorage

@Test func storagePluginInfoIsExposed() {
    #expect(StoragePluginInfo.titleKey == "Storage Settings")
    #expect(PluginStorageLocation.local.rawValue == "local")
}
