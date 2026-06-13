// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) import ApolloAPI

extension SuiGraphQL {
  /// The execution status of this transaction: success or failure.
  nonisolated enum ExecutionStatus: String, EnumType {
    /// The transaction was successfully executed.
    case success = "SUCCESS"
    /// The transaction could not be executed.
    case failure = "FAILURE"
  }

}
