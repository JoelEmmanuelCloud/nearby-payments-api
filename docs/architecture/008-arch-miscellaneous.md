# 008 - Miscellaneous Operations

## Goal

Define the lightweight operational layer for:

- notifications
- observability
- risk monitoring
- logging

This document does not introduce new product authority. It only describes how the system reports, observes, and reacts to events produced by the architecture defined in docs `001` through `007`.

## Core Principle

Operational systems mirror source-of-truth events. They do not create truth.

```text
Bridge:
  deposit delivery state

Sui / SuiNS / custody contracts:
  names, ownership, profile pointers, transaction state

Walrus:
  profile metadata

Backend:
  auth/session state, provider orchestration, event fanout, logs, monitoring

Notifications / observability:
  derived views only
```

## Non-Goals

This document does not define:

- payment settlement
- deposit delivery semantics
- local Radar protocol
- Nearby Assist packet protocol
- profile metadata storage
- AVS authorization rules

Those are owned by earlier architecture docs.

## Notifications

Notifications are user-facing mirrors of already-known state.

Notifications may be sent for:

- KYC required
- KYC pending
- KYC approved/rejected
- virtual account ready
- crypto deposit address ready
- deposit received
- deposit delivery processed
- deposit in review
- payment received
- payment failed
- name registration completed
- name registration failed
- Nearby Assist relay completed
- Nearby Assist relay failed

Notifications must not:

- contain sensitive KYC data
- contain full profile metadata
- contain private transaction payloads
- reveal another user's payment amount unless the recipient UX explicitly requires it
- become the only record of an event

Notification payloads should use compact typed events:

```ts
export type NotificationEvent =
    | {
          type: 'deposit.delivery_processed';
          routeId: string;
          providerEventId: string;
      }
    | {
          type: 'payment.received';
          paymentId: string;
          transactionDigest: string;
      }
    | {
          type: 'name.registration_completed';
          operationId: string;
      };
```

No nullable fields.
No generic notification blob.

## Notification Delivery

Notification delivery should be best-effort.

Suggested channels:

- push notification
- in-app websocket/SSE
- local app state refresh

Delivery failures should not change product state.

Retry only when useful:

```text
push notification:
  bounded retry

in-app event:
  no durable retry if client is disconnected

critical operational anomaly:
  send to anomaly queue
```

## Observability

Observability should answer:

- is the system healthy?
- where are users blocked?
- where are providers failing?
- where are security controls rejecting traffic?
- where are local protocols unreliable?

Track at minimum:

```text
auth:
  OAuth failures
  App Attest failures
  nonce replay attempts
  session refresh failures

Bridge:
  KYC link creation failures
  virtual account creation failures
  liquidation address creation failures
  webhook signature failures
  payment_submitted without payment_processed

AVS:
  authorization latency
  pending rate
  rejection rate
  quorum timeout rate

SuiNS/profile:
  parent renewal deadline
  name registration failures
  leaf mutation failures
  Walrus pointer verification failures

Radar:
  discovery failure rate
  handshake failure rate
  SuiNS mismatch rate
  QR fallback rate

Nearby Assist:
  assist open failures
  keep-alive timeout rate
  relay packet failure rate
  route rejection rate
```

## Metrics

Metrics should be low-cardinality.

Good labels:

```text
environment
route
provider
event_type
failure_reason
platform
auth_fidelity
```

Avoid high-cardinality labels:

```text
user id
device id
wallet address
SuiNS name
transaction digest
provider event id
```

Those belong in structured logs or explicit diagnostic tools, not metric labels.

## Structured Logging

Logs should be structured JSON.

Required fields:

```ts
export type LogRecord = {
    level: 'debug' | 'info' | 'warn' | 'error';
    event: string;
    requestId: string;
    timestamp: string;
    component: string;
    environment: string;
};
```

Optional fields:

```ts
export type OperationalLogFields = {
    userIdHash?: string;
    deviceIdHash?: string;
    routeId?: string;
    providerEventId?: string;
    transactionDigest?: string;
    failureReason?: string;
};
```

Do not log:

- OAuth tokens
- refresh/access tokens
- App Attest assertions
- zkLogin proofs
- private keys
- KYC payloads
- full profile metadata
- avatars
- raw payment payloads
- Nearby Assist plaintext payloads

## Risk Monitoring

Risk monitoring is configurable policy and anomaly detection.

It is not a separate product ledger.

Monitor:

- repeated App Attest failures
- replayed request nonces
- abnormal session refresh patterns
- suspicious sponsorship usage
- high Nearby Assist relay volume
- repeated failed payment submissions
- rapid SuiNS leaf target changes
- repeated Bridge route creation attempts
- webhook signature failures
- unexpected parent custody changes
- high-traffic queue backlog
- idempotency conflict rate

Risk policy may:

- restrict sponsorship
- restrict device credential issuance
- require re-authentication
- pause deposit route creation
- mark a device or session restricted

Risk policy must not:

- mutate user leaf names
- revoke profiles
- alter Bridge KYC status
- create payment truth
- silently block user-paid self-custody transactions that the contract permits

Risk policy should be configuration-driven where possible. Do not hard-code mutable limits that operators may need to tune during abuse events or provider incidents.

## Anomaly Events

Operator-actionable issues should emit anomaly events.

```ts
export type AnomalyEvent = {
    type:
        | 'auth.app_attest_failure_spike'
        | 'bridge.webhook_signature_failure'
        | 'bridge.delivery_stuck'
        | 'avs.quorum_timeout'
        | 'suins.parent_renewal_due'
        | 'nearby_assist.packet_failure_spike';
    severity: 'info' | 'warning' | 'critical';
    title: string;
    body: string;
    createdAt: string;
};
```

Anomaly delivery may target:

- internal dashboard
- Discord/Slack
- email
- paging system

Anomaly events should avoid PII. Include identifiers only when operationally necessary, and prefer hashes or provider IDs.

## Event Fanout

Use internal events to decouple producers from notification/monitoring consumers.

Examples:

```text
auth.session_revoked
bridge.deposit_delivery_processed
avs.authorization_rejected
suins.name_registration_failed
radar.handshake_failed
nearby_assist.relay_completed
```

Event consumers may:

- update metrics
- write logs
- send notifications
- emit anomalies

Event consumers must not become source-of-truth writers unless explicitly owned by that domain.

## Retention

Retention should minimize sensitive operational data.

Suggested defaults:

```text
debug logs:
  short retention

info/warn/error logs:
  moderate retention

security anomaly events:
  longer retention

provider event ids:
  long enough for dedupe and audits

PII-bearing payloads:
  do not store
```

Exact retention windows should be configured per deployment and compliance review.

## Testing Rules

Tests must cover:

- notification payloads do not include forbidden fields
- logs redact tokens and assertions
- metrics avoid high-cardinality labels
- risk policy can restrict sponsorship
- risk policy cannot mutate user leaf names
- anomaly events avoid profile/KYC PII
- event fanout failure does not alter source-of-truth state
- Nearby Assist plaintext payloads are never logged

## Review Checklist

Before adding operational instrumentation, verify:

- Is this derived from a source-of-truth event?
- Does it avoid PII?
- Does it avoid auth secrets and cryptographic material?
- Is the metric low-cardinality?
- Is the log structured?
- Is the notification safe for lock screen display?
- Does risk policy avoid mutating user-owned state?
- Is anomaly delivery useful to an operator?
