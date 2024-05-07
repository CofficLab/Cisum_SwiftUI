import Foundation
import OSLog

extension DB {
    func prepareJob() {
        Task.detached(operation: {
            await self.prepare()
        })
    }
    
    private func prepare() async {
        guard let first = get(0) else {
            return
        }
        
        downloadNext(first, reason: "\(Logger.isMain)\(self.label)prepare")
    }
}
