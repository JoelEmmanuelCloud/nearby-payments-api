//
//  Event+Mapping.swift
//  LeanSuiApi
//
//  Conversions for the event endpoint: generated `RPC_EVENTS_FIELDS` -> domain
//  `SuiEvent`, and domain `SuiEventFilter` -> generated `EventFilter` input.
//

import ApolloAPI
import Foundation

extension SuiEvent {
  init(graphql f: RPC_EVENTS_FIELDS) throws {
    self.init(
      packageId: f.transactionModule?.package?.address,
      transactionModule: f.transactionModule?.name,
      sender: f.sender?.address,
      type: f.contents?.type?.repr,
      json: f.contents?.json?.string,
      bcs: f.contents?.bcs,
      timestamp: try f.timestamp.map { try Scalars.date($0, field: "event.timestamp") }
    )
  }
}

extension PageInfo {
  init(graphql p: QueryEventsQuery.Data.Events.PageInfo) {
    self.init(
      hasNextPage: p.hasNextPage,
      hasPreviousPage: p.hasPreviousPage,
      startCursor: p.startCursor,
      endCursor: p.endCursor
    )
  }
}

extension EventFilter {
  init(domain f: SuiEventFilter) {
    func nullable(_ s: String?) -> GraphQLNullable<String> { s.map { .some($0) } ?? .null }
    func nullableU53(_ v: UInt64?) -> GraphQLNullable<UInt53> {
      v.map { .some(String($0)) } ?? .null
    }
    self.init(
      afterCheckpoint: nullableU53(f.afterCheckpoint),
      atCheckpoint: nullableU53(f.atCheckpoint),
      beforeCheckpoint: nullableU53(f.beforeCheckpoint),
      sender: nullable(f.sender),
      module: nullable(f.transactionModule),
      type: nullable(f.eventType)
    )
  }
}
