# 001 - Backend Code Organization

## Goal

Standardize how the nearby payments backend is organized so each feature follows the same route, schema, service, store, worker, error, and monitoring boundaries.

The backend should stay:

- explicit
- domain-oriented
- strict at the API boundary
- OpenAPI documented
- Cloudflare-native
- easy to test with injected dependencies

## Core Rule

Routes should not contain business logic.

The normal request flow is:

```text
route -> schema -> middleware -> service -> store/provider -> response
```

Routes parse and authorize.
Schemas define the external contract.
Services decide.
Stores persist.
Workers process async work.
Utilities stay generic.

## Folder Layout

```text
src/
  app.ts
  index.ts

  routes/
  schemas/
  middleware/
  services/
  stores/
  workers/
  durable-objects/
  events/
  webhooks/
  monitoring/
  errors/
  utils/
  constants/
  types/
```

Use this structure consistently. Add a new top-level folder only when the code cannot reasonably fit one of these categories.

## API Contract

The backend uses REST-style HTTP routes documented with OpenAPI.

Use resource-oriented routes where possible:

```text
POST /v1/nearby/sessions
GET  /v1/nearby/sessions/{sessionId}
POST /v1/payment-intents
GET  /v1/payment-intents/{intentId}
GET  /v1/payments/{paymentId}
```

Use action subroutes when the operation is not a normal CRUD operation:

```text
POST /v1/nearby/sessions/{sessionId}/verify
POST /v1/payment-intents/{intentId}/submit
POST /v1/payment-intents/{intentId}/cancel
POST /v1/assist/sessions/{assistSessionId}/relay
```

Every route must define:

- request schema
- success response schema
- error response schema
- auth requirement
- idempotency behavior when relevant

Provider webhooks may keep provider-native payload shapes, but they must be validated and adapted into internal events immediately.

## Routes

Routes define HTTP topology and middleware order.

Routes may:

- mount Hono handlers
- attach OpenAPI/Zod validation
- attach auth, device, idempotency, or risk middleware
- call one service method
- return typed JSON responses

Routes must not:

- query D1, KV, Durable Objects, or queues directly
- call third-party APIs directly
- contain payment state machines
- normalize malformed input
- implement retry logic

Preferred shape:

```ts
routes.post(
    '/payment-intents',
    validateJson(paymentIntentCreateSchema),
    auth('high', options),
    idempotency(options),
    async (c) => {
        const input = c.req.valid('json');
        const session = c.get('session');
        const result = await createPaymentIntentService(c.env, options).create({
            userId: session.userId,
            input,
        });

        return c.json(result, 201);
    },
);
```

## Schemas

Schemas are the runtime contract for all external input.

Use Zod for:

- JSON request bodies
- route params
- query params
- webhook payloads
- queue messages
- public response bodies
- provider callback bodies

Schemas should be strict by default.

```ts
export const paymentAmountSchema = z
    .object({
        asset: z.literal('USDsui'),
        amountAtomic: z.string().regex(/^[0-9]+$/),
    })
    .strict();
```

Schemas should not:

- silently coerce business-critical values
- normalize names, addresses, or amounts
- call services
- read environment bindings
- contain provider calls

If normalization is truly required, put it in a clearly named service or utility after validation.

## Services

Services own business logic.

A service may:

- enforce product rules
- validate state transitions
- call stores
- call provider clients
- compose multiple stores and providers
- emit internal events
- decide whether async work should be queued

A service must not:

- depend on Hono context
- return raw provider responses unless the route explicitly exposes that provider contract
- know about HTTP response formatting
- perform direct SQL/KV operations

Preferred shape:

```ts
export function createPaymentIntentService(env: Env, options: CreateAppOptions = {}) {
    const paymentStore = createPaymentIntentStore(env);
    const recipientResolver = createRecipientResolverService(env, options);

    return {
        async create(input: CreatePaymentIntentInput): Promise<PaymentIntentRecord> {
            // Business logic only.
        },
    };
}
```

## Stores

Stores are persistence adapters.

Stores may:

- read and write D1
- read and write KV
- access Durable Object stubs
- map database rows to typed records
- implement persistence-specific pagination

Stores must not:

- enforce product policy
- call third-party APIs
- emit notifications
- know about HTTP routes
- know about OpenAPI response shapes

Use one store per persistence domain:

```text
stores/auth.ts
stores/devices.ts
stores/wallets.ts
stores/profiles.ts
stores/funding.ts
stores/payment-sessions.ts
stores/payment-intents.ts
stores/settlement.ts
stores/webhook-events.ts
```

## Workers

Workers handle async execution only.

Use workers for:

- Sui settlement reconciliation
- Bridge webhook processing
- notification fanout
- anomaly delivery
- expired session cleanup
- retryable provider work
- high-traffic actions that should not block a request thread

Workers must not become a second application layer.

Queue payloads should be small and should carry routing identity, not full domain state.

```ts
export type SettlementQueueMessage = {
    paymentIntentId: string;
    txDigest: string;
    attempt: number;
};
```

The worker should load full state from stores before acting.

## Durable Objects

Use Durable Objects only when atomic per-key coordination is required.

Good use cases:

- one active receive session per recipient device
- payment admission per payer
- payment session race prevention
- Nearby Assist relay session coordination
- atomic transaction submission or sponsorship admission for a deployment target

Do not use Durable Objects as general databases. Durable state that needs relational querying belongs in D1.

Do not duplicate Durable Object domains for the same atomic workflow. If a transaction path already passes through a Durable Object or equivalent atomic primitive for the deployment target, reuse that boundary instead of adding a second coordination layer.

## Idempotency And Queues

Use idempotency keys for operations where retries can create duplicate external effects.

Required examples:

- provider route creation
- Bridge webhook processing
- AVS authorization tasks
- sponsorship admission
- transaction submission or relay
- name registration

Any high-traffic, bursty, retryable, or slow operation should be placed behind a queue when it does not need to complete inside the user request.

Queue when:

- provider latency is unpredictable
- AVS quorum may be pending
- webhook processing can spike
- transaction submission can be retried safely
- operator notifications/anomalies may fan out
- a route can acknowledge admission now and complete processing later

Do not queue merely to hide unclear ownership. The queue dispatches work; the domain service still owns the state transition.

## Types

Types define internal domain records and service contracts.

Use `types/` for:

- Cloudflare bindings
- Hono context variables
- database records
- service inputs and results
- worker messages
- provider abstractions
- internal event shapes

Do not manually duplicate schema-derived types when Zod can infer them.

```ts
export type PaymentIntentCreateInput = z.infer<typeof paymentIntentCreateSchema>;
```

Keep provider-native types separate from internal domain types. Adapt provider responses at the service boundary.

## Constants

Constants are named policy and configuration values used across modules.

Use constants for:

- TTLs
- supported assets
- route names
- auth header names
- webhook event names
- risk limits
- queue names
- provider identifiers

Do not put environment-specific secrets in constants.

```ts
export const PAYMENT_INTENT_TTL_SECONDS = 120;
export const SUPPORTED_PAYMENT_ASSET = 'USDsui';
```

## Utilities

Utilities must be generic and side-effect-light.

Good utilities:

- ID generation
- time helpers
- amount formatting and parsing
- response helpers
- address format checks
- hash and signature helpers
- safe JSON parsing

Bad utilities:

- `createPaymentIntent`
- `verifyBridgeWebhookAndUpdateDeposit`
- `resolveRecipientAndCreateSession`

Those belong in services.

## Error Management

Use typed application errors.

Errors should be:

- stable
- machine-readable
- safe to return to clients
- consistently mapped to HTTP responses
- specific enough for clients to act on

Suggested layout:

```text
errors/
  index.ts
  app-error.ts
  auth-errors.ts
  device-errors.ts
  payment-errors.ts
  funding-errors.ts
  provider-errors.ts
```

Example:

```ts
export const PAYMENT_ERRORS = {
    recipientNotFound: {
        code: 'recipient_not_found',
        message: 'Recipient not found',
        httpStatus: 404,
    },
};
```

Services throw `AppError`.
Routes convert `AppError` into typed JSON error responses.
Unexpected errors are logged and returned as internal errors.

Do not leak provider secrets, raw stack traces, or sensitive payment data in client-facing errors.

## Events And Webhooks

Separate internal events from external webhooks.

```text
events/
  funding.ts
  payment.ts
  settlement.ts
  notification.ts

webhooks/
  bridge.ts
```

Internal events are product-domain facts:

```ts
export type PaymentSettledEvent = {
    type: 'payment.settled';
    paymentId: string;
    intentId: string;
    txDigest: string;
    occurredAt: string;
};
```

Webhooks must:

- verify signatures
- store raw event payloads
- dedupe by provider event id
- adapt provider payloads into internal events
- enqueue processing when work may be slow or retryable
- return quickly

Webhook handlers should not perform complex settlement inline.

## Monitoring

Monitoring should be explicit and centralized.

```text
monitoring/
  logger.ts
  metrics.ts
  anomalies.ts
```

Track at minimum:

- auth failures
- App Attest failures
- replayed nonce attempts
- payment intent creation
- payment submission failures
- Sui reconciliation lag
- Bridge webhook failures
- expired nearby sessions
- Nearby Assist relay failures
- duplicate or replayed requests

Use anomaly queues for operator-actionable failures. Do not bury operationally important failures in plain logs only.

## Naming Rules

Use domain-first filenames:

```text
payment-intent.ts
payment-session.ts
nearby-assist.ts
settlement.ts
bridge-customer.ts
deposit-route.ts
```

Avoid vague filenames:

```text
helpers.ts
manager.ts
processor.ts
common.ts
data.ts
misc.ts
```

Prefer explicit exported factory names:

```ts
createPaymentIntentService()
createPaymentIntentStore()
createSettlementWorker()
```

## Testing Rules

Every domain should be testable without real Cloudflare bindings or provider APIs.

Services should accept injected dependencies through `CreateAppOptions` or equivalent test options.

Test by layer:

- schemas reject bad payloads
- routes enforce middleware and auth behavior
- services enforce state transitions
- stores map records correctly
- workers retry and emit anomalies correctly
- webhooks verify signatures and dedupe events

Tests should prove behavior, not implementation details.

## Review Checklist

Before adding a new module, check:

- Does this belong in route, schema, service, store, worker, utility, or type code?
- Is external input validated at the boundary?
- Is business logic outside the route?
- Is durable state in the right storage primitive?
- Is async work queued instead of blocking a webhook or user request?
- Are errors typed and safe?
- Can the feature be tested with injected dependencies?
