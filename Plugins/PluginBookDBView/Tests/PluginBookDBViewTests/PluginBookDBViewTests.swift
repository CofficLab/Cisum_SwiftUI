import Testing
@testable import PluginBookDBView

@Test func bookDBInfoExportsMetadata() {
    #expect(BookDBPluginInfo.table == "Book-DBView")
    #expect(BookDBPluginInfo.iconName == "books.vertical")
}
