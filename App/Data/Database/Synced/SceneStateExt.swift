import Foundation
import OSLog
import SwiftData

extension DBSynced {
    // MARK: Find
    
    func findSceneState(_ scene: DiskScene, reason: String, verbose: Bool = true) -> SceneState? {
        if verbose {
            os_log("\(self.label)FindSceneState for \(scene.title) because of \(reason)")
        }
        
        do {
            return try context.fetch(SceneState.descriptorOf(scene)).first
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
            
            return nil
        }
    }
    
    func getSceneCurrent(_ scene: DiskScene, reason: String) -> URL? {
        return self.findSceneState(scene, reason: reason)?.currentURL
    }
    
    // MARK: Update
    
    func updateSceneCurrent(_ scene: DiskScene, currentURL: URL?) {
        os_log("\(self.label)UpdateSceneCurrent: \(scene.title) -> \(currentURL?.lastPathComponent ?? "")")
        if let state = self.findSceneState(scene, reason: "UpdateSceneCurrent") {
            state.currentURL = currentURL
        } else {
            context.insert(SceneState(scene: scene, currentURL: currentURL))
        }
        
        do {
            try context.save()
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }
}
