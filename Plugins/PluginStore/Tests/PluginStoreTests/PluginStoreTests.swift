import Testing
@testable import PluginStore

@Test func storeInfoExportsMetadata() {
    #expect(StorePluginInfo.titleKey == "Store")
    #expect(StorePluginInfo.iconName == "cart")
    #expect(SubscriptionTier.none.isFreeVersion)
}

@Test func productListShowsLoadingErrorEmptyAndContentStates() {
    #expect(StoreProductListPresentation.state(
        isRefreshing: true,
        hasGroups: false,
        hasError: false
    ) == .loading)

    #expect(StoreProductListPresentation.state(
        isRefreshing: false,
        hasGroups: false,
        hasError: true
    ) == .error)

    #expect(StoreProductListPresentation.state(
        isRefreshing: false,
        hasGroups: false,
        hasError: false
    ) == .empty)

    #expect(StoreProductListPresentation.state(
        isRefreshing: true,
        hasGroups: true,
        hasError: true
    ) == .content)
}

@Test func productListOnlyAppliesLatestLoadResult() {
    #expect(StoreProductLoadPolicy.shouldApplyResult(
        currentGeneration: 3,
        resultGeneration: 3
    ))
    #expect(!StoreProductLoadPolicy.shouldApplyResult(
        currentGeneration: 3,
        resultGeneration: 2
    ))
}
