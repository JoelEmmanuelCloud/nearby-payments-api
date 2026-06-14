import Foundation

/// Thrown by `withTimeout` when an operation outruns its deadline.
struct TimeoutError: LocalizedError {
  var errorDescription: String? { "The request timed out." }
}

/// Runs `operation`, throwing `TimeoutError` if it hasn't completed within `seconds`. Used to bound
/// network calls (name checks, name resolution, activity refresh) so a stalled request surfaces a
/// toast instead of spinning forever.
func withTimeout<T: Sendable>(
  seconds: TimeInterval,
  _ operation: @escaping @Sendable () async throws -> T
) async throws -> T {
  try await withThrowingTaskGroup(of: T.self) { group in
    group.addTask { try await operation() }
    group.addTask {
      try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
      throw TimeoutError()
    }
    defer { group.cancelAll() }
    return try await group.next()!
  }
}
