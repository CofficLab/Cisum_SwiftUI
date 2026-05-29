import Testing
@testable import PluginStore

@Test func storeInfoExportsMetadata() {
    #expect(StorePluginInfo.titleKey == "Store")
    #expect(StorePluginInfo.iconName == "cart")
    #expect(SubscriptionTier.none.isFreeVersion)
}
