import Foundation

// MARK: - Safe Collection Subscript

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Timeout Error

enum TimeoutError: LocalizedError {
    case timedOut(seconds: Double)

    var errorDescription: String? {
        switch self {
        case .timedOut(let seconds):
            return "Request timed out after \(Int(seconds)) seconds. Please check your connection and try again."
        }
    }
}

// MARK: - Async Timeout Helper

/// Runs an async throwing closure with a deadline. If the closure doesn't
/// complete within `seconds`, a `TimeoutError.timedOut` is thrown and the
/// child task is cancelled.
func withTimeout<T: Sendable>(
    seconds: Double,
    operation: @escaping @Sendable () async throws -> T
) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        // The real work
        group.addTask {
            try await operation()
        }

        // The timeout
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw TimeoutError.timedOut(seconds: seconds)
        }

        // Whichever finishes first wins; cancel the other.
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}
