// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct QueryEventsQuery: GraphQLQuery {
    static let operationName: String = "queryEvents"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query queryEvents($filter: EventFilter!, $before: String, $after: String, $first: Int, $last: Int) { events( filter: $filter first: $first after: $after last: $last before: $before ) { __typename pageInfo { __typename hasNextPage hasPreviousPage endCursor startCursor } nodes { __typename ...RPC_EVENTS_FIELDS } } }"#,
        fragments: [RPC_EVENTS_FIELDS.self]
      ))

    public var filter: EventFilter
    public var before: GraphQLNullable<String>
    public var after: GraphQLNullable<String>
    public var first: GraphQLNullable<Int32>
    public var last: GraphQLNullable<Int32>

    public init(
      filter: EventFilter,
      before: GraphQLNullable<String>,
      after: GraphQLNullable<String>,
      first: GraphQLNullable<Int32>,
      last: GraphQLNullable<Int32>
    ) {
      self.filter = filter
      self.before = before
      self.after = after
      self.first = first
      self.last = last
    }

    @_spi(Unsafe) public var __variables: Variables? {
      [
        "filter": filter,
        "before": before,
        "after": after,
        "first": first,
        "last": last,
      ]
    }

    nonisolated struct Data: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field(
            "events", Events?.self,
            arguments: [
              "filter": .variable("filter"),
              "first": .variable("first"),
              "after": .variable("after"),
              "last": .variable("last"),
              "before": .variable("before"),
            ])
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          QueryEventsQuery.Data.self
        ]
      }

      /// Paginate events that are emitted in the network, optionally filtered by event filters.
      var events: Events? { __data["events"] }

      /// Events
      ///
      /// Parent Type: `EventConnection`
      nonisolated struct Events: SuiGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.EventConnection }
        static var __selections: [ApolloAPI.Selection] {
          [
            .field("__typename", String.self),
            .field("pageInfo", PageInfo.self),
            .field("nodes", [Node].self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            QueryEventsQuery.Data.Events.self
          ]
        }

        /// Information to aid in pagination.
        var pageInfo: PageInfo { __data["pageInfo"] }
        /// A list of nodes.
        var nodes: [Node] { __data["nodes"] }

        /// Events.PageInfo
        ///
        /// Parent Type: `PageInfo`
        nonisolated struct PageInfo: SuiGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.PageInfo }
          static var __selections: [ApolloAPI.Selection] {
            [
              .field("__typename", String.self),
              .field("hasNextPage", Bool.self),
              .field("hasPreviousPage", Bool.self),
              .field("endCursor", String?.self),
              .field("startCursor", String?.self),
            ]
          }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
            [
              QueryEventsQuery.Data.Events.PageInfo.self
            ]
          }

          /// When paginating forwards, are there more items?
          var hasNextPage: Bool { __data["hasNextPage"] }
          /// When paginating backwards, are there more items?
          var hasPreviousPage: Bool { __data["hasPreviousPage"] }
          /// When paginating forwards, the cursor to continue.
          var endCursor: String? { __data["endCursor"] }
          /// When paginating backwards, the cursor to continue.
          var startCursor: String? { __data["startCursor"] }
        }

        /// Events.Node
        ///
        /// Parent Type: `Event`
        nonisolated struct Node: SuiGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Event }
          static var __selections: [ApolloAPI.Selection] {
            [
              .field("__typename", String.self),
              .fragment(RPC_EVENTS_FIELDS.self),
            ]
          }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
            [
              QueryEventsQuery.Data.Events.Node.self,
              RPC_EVENTS_FIELDS.self,
            ]
          }

          /// The module containing the function that was called in the programmable transaction, that resulted in this event being emitted.
          var transactionModule: TransactionModule? { __data["transactionModule"] }
          /// Address of the sender of the transaction that emitted this event.
          var sender: Sender? { __data["sender"] }
          /// The Move value emitted for this event.
          var contents: Contents? { __data["contents"] }
          /// Timestamp corresponding to the checkpoint this event's transaction was finalized in.
          /// All events from the same transaction share the same timestamp.
          ///
          /// `null` for simulated/executed transactions as they are not included in a checkpoint.
          var timestamp: SuiGraphQL.DateTime? { __data["timestamp"] }

          struct Fragments: FragmentContainer {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            var rPC_EVENTS_FIELDS: RPC_EVENTS_FIELDS { _toFragment() }
          }

          typealias TransactionModule = RPC_EVENTS_FIELDS.TransactionModule

          typealias Sender = RPC_EVENTS_FIELDS.Sender

          typealias Contents = RPC_EVENTS_FIELDS.Contents
        }
      }
    }
  }

}
