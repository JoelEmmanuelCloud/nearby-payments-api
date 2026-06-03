// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct GetTypeLayoutQuery: GraphQLQuery {
    static let operationName: String = "getTypeLayout"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query getTypeLayout($type: String!) { type(type: $type) { __typename layout } }"#
      ))

    public var type: String

    public init(type: String) {
      self.type = type
    }

    @_spi(Unsafe) public var __variables: Variables? { ["type": type] }

    nonisolated struct Data: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("type", Type_SelectionSet?.self, arguments: ["type": .variable("type")])
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          GetTypeLayoutQuery.Data.self
        ]
      }

      /// Fetch a structured representation of a concrete type, including its layout information.
      ///
      /// Types are canonicalized: In the input they can be at any package address at or after the package that first defines them, and in the output they will be relocated to the package that first defines them.
      ///
      /// Fails if the type is malformed, returns `null` if a type mentioned does not exist.
      var type: Type_SelectionSet? { __data["type"] }

      /// Type_SelectionSet
      ///
      /// Parent Type: `MoveType`
      nonisolated struct Type_SelectionSet: SuiGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveType }
        static var __selections: [ApolloAPI.Selection] {
          [
            .field("__typename", String.self),
            .field("layout", SuiGraphQL.MoveTypeLayout?.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            GetTypeLayoutQuery.Data.Type_SelectionSet.self
          ]
        }

        /// Structured representation of the "shape" of values that match this type. May return no
        /// layout if the type is invalid.
        var layout: SuiGraphQL.MoveTypeLayout? { __data["layout"] }
      }
    }
  }

}
