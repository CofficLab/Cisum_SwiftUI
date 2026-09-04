import Testing
import DevicePlugin

@Test func devicePluginExportsSyncedDatabaseActor() async throws {
    #expect(DBSynced.emoji == "📦")
}
