import Testing
import Foundation
@testable import TeleportMe

// MARK: - AsyncHelpers Tests

struct AsyncHelpersTests {

    // MARK: - Safe Subscript Tests

    @Test func safeSubscript_inBounds() {
        let array = [10, 20, 30]
        #expect(array[safe: 0] == 10)
        #expect(array[safe: 1] == 20)
        #expect(array[safe: 2] == 30)
    }

    @Test func safeSubscript_outOfBounds() {
        let array = [10, 20, 30]
        #expect(array[safe: 3] == nil)
        #expect(array[safe: 100] == nil)
    }

    @Test func safeSubscript_emptyCollection() {
        let empty: [Int] = []
        #expect(empty[safe: 0] == nil)
    }

    @Test func safeSubscript_worksWithStrings() {
        let strings = ["hello", "world"]
        #expect(strings[safe: 0] == "hello")
        #expect(strings[safe: 2] == nil)
    }

    // MARK: - TimeoutError Tests

    @Test func timeoutError_description() {
        let error = TimeoutError.timedOut(seconds: 30.0)
        #expect(error.errorDescription?.contains("30") == true)
        #expect(error.errorDescription?.contains("timed out") == true)
    }

    @Test func timeoutError_formatsAsInt() {
        let error = TimeoutError.timedOut(seconds: 15.5)
        // Uses Int(seconds) so 15.5 → "15"
        #expect(error.errorDescription?.contains("15") == true)
    }

    // MARK: - withTimeout Tests

    @Test func withTimeout_operationCompletesBeforeTimeout() async throws {
        let result = try await withTimeout(seconds: 5.0) {
            return 42
        }
        #expect(result == 42)
    }

    @Test func withTimeout_operationExceedsTimeout_throws() async {
        do {
            _ = try await withTimeout(seconds: 0.1) {
                try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
                return 42
            }
            #expect(Bool(false), "Should have thrown TimeoutError")
        } catch is TimeoutError {
            // Expected
        } catch {
            #expect(Bool(false), "Expected TimeoutError, got \(error)")
        }
    }
}
