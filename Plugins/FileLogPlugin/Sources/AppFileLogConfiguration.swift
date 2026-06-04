import Foundation

struct AppFileLogConfiguration: FileLogConfiguration {
    func logsDirectory() -> URL {
        FileLogDirectory.defaultLogsDirectory()
    }
}
