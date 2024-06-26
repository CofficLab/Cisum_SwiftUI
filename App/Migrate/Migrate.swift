import OSLog

struct Migrate {
    static var label = "🐯 Migrate::"
    
    var label: String {
        "\(Logger.isMain)\(Self.label)"
    }
}
