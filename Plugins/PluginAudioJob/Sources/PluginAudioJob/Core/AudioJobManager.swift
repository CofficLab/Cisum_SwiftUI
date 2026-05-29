import Foundation
import OSLog

public actor AudioJobManager {
    public static let shared = AudioJobManager()

    public nonisolated static let verbose = false

    private var jobs: [String: any AudioJob] = [:]
    private var runningJobs: Set<String> = []

    private init() {}

    public func register(_ job: any AudioJob) {
        jobs[job.identifier] = job

        if Self.verbose {
            os_log("📋 Audio job registered: \(job.identifier) - \(job.name)")
        }
    }

    public func unregister(_ identifier: String) {
        jobs.removeValue(forKey: identifier)
        runningJobs.remove(identifier)

        if Self.verbose {
            os_log("🗑️ Audio job unregistered: \(identifier)")
        }
    }

    public func startJob(_ identifier: String) {
        guard let job = jobs[identifier] else {
            os_log(.error, "❌ Audio job does not exist: \(identifier)")
            return
        }

        if runningJobs.contains(identifier) {
            if Self.verbose {
                os_log("⚠️ Audio job already running: \(identifier)")
            }
            return
        }

        runningJobs.insert(identifier)

        if Self.verbose {
            os_log("🚀 Audio job started: \(job.name)")
        }

        Task { [weak self] in
            do {
                try await job.execute()
            } catch is CancellationError {
                if Self.verbose {
                    os_log("⏹️ Audio job cancelled: \(identifier)")
                }
            } catch {
                os_log(.error, "❌ Audio job failed [\(identifier)]: \(error)")
            }

            await self?.markJobFinished(identifier)
        }
    }

    public func stopJob(_ identifier: String) {
        guard let job = jobs[identifier] else {
            os_log(.error, "❌ Audio job does not exist: \(identifier)")
            return
        }

        job.cancel()
        runningJobs.remove(identifier)

        if Self.verbose {
            os_log("⏹️ Audio job stopped: \(identifier)")
        }
    }

    public func stopAllJobs() {
        for identifier in runningJobs {
            jobs[identifier]?.cancel()
        }
        runningJobs.removeAll()

        if Self.verbose {
            os_log("⏹️ All audio jobs stopped")
        }
    }

    public func getAllJobStatus() -> [JobStatus] {
        jobs.values.map { job in
            JobStatus(
                identifier: job.identifier,
                name: job.name,
                isRunning: runningJobs.contains(job.identifier)
            )
        }
    }

    public func getJobStatus(_ identifier: String) -> JobStatus? {
        guard let job = jobs[identifier] else {
            return nil
        }

        return JobStatus(
            identifier: identifier,
            name: job.name,
            isRunning: runningJobs.contains(identifier)
        )
    }

    private func markJobFinished(_ identifier: String) {
        runningJobs.remove(identifier)
    }
}
