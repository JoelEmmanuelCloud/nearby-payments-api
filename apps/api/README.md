# Nearby Payments — Backend

Go backend for the Nearby Payments product built for Sui Overflow 2026.

Nearby Payments is a hybrid fintech app that lets users discover each other via BLE/proximity, verify payment identity through SuiNS, and settle peer payments on the Sui blockchain — funded by USD deposits via Bridge virtual accounts and crypto liquidation addresses.

---

## Stack

| Layer | Choice |
|---|---|
| Language | Go 1.22+ |
| Framework | [Chi](https://github.com/go-chi/chi) |
| Database | PostgreSQL (Railway) |
| Cache / Session | Redis (Upstash) |
| Blockchain | Sui (via [sui-go-sdk](https://github.com/blockvisionhq/sui-go-sdk)) |
| Fiat onramp | [Bridge](https://bridge.xyz) |
| Deployment | Railway |

---

## Repository Structure

```
cmd/
  api/
    main.go               # entry point

internal/
  config/
    config.go             # env vars, Railway + Upstash bindings

  domain/
    auth/
      handler.go          # POST /v1/auth/session
      service.go          # session creation, zkLogin salt, token issuance
      store.go            # users, sessions, devices, wallet_bindings (Postgres)
      middleware.go        # auth() middleware — low / high fidelity
      errors.go
      types.go

    deposit/
      handler.go          # GET /v1/deposit-routes/options
      service.go          # Bridge KYC + virtual account + liquidation address logic
      store.go            # bridge_links, deposit_routes (Postgres)
      bridge_client.go    # Bridge API wrapper
      webhook.go          # POST /v1/webhooks/bridge
      errors.go
      types.go

    payment/
      handler.go          # POST /v1/payment-intents, POST .../submit
      service.go          # intent creation, Sui tx relay
      store.go            # payment_intents, payments (Postgres)
      errors.go
      types.go

    names/
      handler.go          # POST /v1/names
      service.go          # SuiNS leaf registration (AVS-backed)
      store.go            # name_operation_tasks (Postgres)
      errors.go
      types.go

    nearby/
      handler.go          # POST /v1/nearby/sessions, POST .../verify
      service.go          # session creation, device credential issuance
      store.go            # nearby_sessions (Postgres + Redis TTL)
      errors.go
      types.go

  avs/
    client.go             # AVS client — typed methods only
    aggregator.go         # collect 3-of-5 signatures
    operator.go           # operator signer interface + stub implementation
    types.go
    errors.go

  sui/
    client.go             # sui-go-sdk wrapper
    multisig.go           # 3-of-5 sponsor multisig construction
    sponsor.go            # sponsored tx construction and submission
    types.go

  middleware/
    idempotency.go
    request_id.go
    logging.go
    recovery.go

  db/
    postgres.go           # connection pool
    redis.go              # Upstash Redis client
    migrations/
      001_auth.sql
      002_deposit.sql
      003_payment.sql
      004_names.sql
      005_nearby.sql
      006_avs.sql

  errors/
    app_error.go          # typed AppError
    http.go               # AppError -> JSON HTTP response

  utils/
    id.go                 # ID generation (ULID)
    crypto.go             # hashing, nonce generation
    time.go

router/
  router.go               # mounts all domain handlers

Makefile
railway.toml
.env.example
```

---

## API Routes

### Auth
```
POST   /v1/auth/oauth/begin              # start OAuth flow
POST   /v1/auth/oauth/complete           # complete OAuth + issue session
POST   /v1/auth/session/refresh          # refresh access token (high fidelity)
DELETE /v1/auth/session                  # revoke session
POST   /v1/devices/integrity/assert      # platform device integrity assertion (high fidelity)
POST   /v1/devices/nearby-credential     # issue device identity credential (high fidelity)
```

### Deposit Routes
```
GET    /v1/deposit-routes/options        # get fiat + crypto deposit state (low fidelity)
POST   /v1/webhooks/bridge               # Bridge webhook ingestion
```

### Payments
```
POST   /v1/payment-intents               # create payment intent (high fidelity)
GET    /v1/payment-intents/:id           # get intent status (low fidelity)
POST   /v1/payment-intents/:id/submit    # submit signed Sui tx (high fidelity)
POST   /v1/payment-intents/:id/cancel    # cancel intent (high fidelity)
GET    /v1/payments/:id                  # get payment result (low fidelity)
```

### Names (SuiNS)
```
POST   /v1/names                         # claim leaf name (high fidelity)
GET    /v1/names/:label                  # resolve name status
```

### Nearby Sessions
```
POST   /v1/nearby/sessions               # create receive session (high fidelity)
GET    /v1/nearby/sessions/:id           # get session (low fidelity)
POST   /v1/nearby/sessions/:id/verify    # verify peer (high fidelity)
```

### Health
```
GET    /health
```

---

## Auth Fidelity Model

Routes enforce one of two auth modes:

**Low fidelity** — valid access token + active session + active device record.
Used for reads and non-mutating operations.

**High fidelity** — low fidelity + platform device integrity proof + request nonce + timestamp window + body hash.
Required for all money-path and trust-path mutations.

> **Hackathon scope:** High fidelity auth is implemented with the correct interface but uses a simplified device integrity stub (no real Apple App Attest / Google Play Integrity). The interface is identical — swapping in real providers requires only changing the verifier implementation.

```go
// middleware/auth.go
func Auth(fidelity string) func(http.Handler) http.Handler
// fidelity: "low" | "high"
```

---

## AVS (Actively Validated Service)

The AVS boundary prevents any single backend process from unilaterally authorizing sensitive protocol actions.

**Production design:** 3-of-5 independent signer microservices. Each holds one Ed25519 Sui keypair. A Sui multisig address is derived from all 5 public keys with threshold 3. The aggregator collects the first 3 valid signatures before returning authorization.

**Hackathon implementation:** 5 Ed25519 keypairs are generated at startup and held in memory. The aggregator signs with 3 of them internally, producing a valid Sui 3-of-5 multisig signature. From the Sui contract's perspective, this is identical to a real distributed AVS.

**Allowed actions only:**
```go
const (
    AVSActionLeafRegisterInitial = "leaf_name.register_initial"
    AVSActionParentRenew         = "parent_name.renew"
    AVSActionParentAdminRecover  = "parent_name.admin_recover"
    AVSActionSponsorTxApprove    = "sponsor_tx.approve"
)
```

The AVS client exposes typed methods only — there is no generic `SignTransaction()` method.

---

## Deposit Routes (Bridge Integration)

Bridge handles all fiat onramp and crypto deposit route lifecycle.

**Fiat USD flow:**
1. Backend creates a Bridge hosted KYC link for new users
2. Client opens the Bridge KYC/ToS URL in-app
3. Once approved, backend ensures a Bridge USD virtual account exists
4. User receives USD bank account details (ACH + wire)
5. Bridge converts incoming USD → USDC → delivers to user's Sui address

**Crypto flow:**
- Bridge EVM liquidation address (USDC, multichain)
- Bridge Solana liquidation addresses (USDC + USDT)
- No separate KYC required for crypto routes

**Response shape — always a discriminated union:**
```go
type FiatUsdDepositState struct {
    Kind string // "kyc_required" | "kyc_pending" | "account_details"
    // ...fields per kind, no nullable state-critical fields
}
```

---

## Database Schema

### Auth
```sql
users, oauth_identities, devices, device_integrity_records,
sessions, zklogin_salts, wallet_bindings
```

### Deposit
```sql
bridge_links, deposit_routes, bridge_webhook_events
```

### Payments
```sql
payment_intents, payments
```

### Names
```sql
name_operation_tasks
```

### Nearby
```sql
nearby_sessions
```

### AVS
```sql
avs_authorization_tasks
```

Full migration SQL in `internal/db/migrations/`.

---

## Getting Started

### Prerequisites
- Go 1.22+
- PostgreSQL
- Redis (Upstash free tier works)
- Bridge sandbox account — email `support@bridge.xyz` for developer access

### Environment Variables

Copy `.env.example` to `.env`:

```env
# Server
PORT=8080
ENV=development

# Postgres (Railway provides this automatically)
DATABASE_URL=postgresql://user:pass@host:5432/nearby

# Redis (Upstash)
REDIS_URL=rediss://default:password@host.upstash.io:6379

# Sui
SUI_RPC_URL=https://fullnode.testnet.sui.io:443
SUI_NETWORK=testnet

# Bridge (sandbox)
BRIDGE_API_KEY=your_sandbox_api_key
BRIDGE_API_URL=https://api.sandbox.bridge.xyz
BRIDGE_WEBHOOK_SECRET=your_webhook_secret

# Auth
ACCESS_TOKEN_SECRET=32_byte_random_secret
REFRESH_TOKEN_SECRET=32_byte_random_secret
SESSION_ENCRYPTION_KEY=32_byte_random_key

# AVS (generated at first boot in dev, set explicitly in prod)
# AVS_OPERATOR_KEYS=comma_separated_hex_private_keys (5 keys)

# OAuth
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
```

### Run Locally

```bash
# Install dependencies
go mod download

# Run migrations
make migrate

# Start server
make dev

# Or directly
go run cmd/api/main.go
```

### Run on Railway

1. Connect your GitHub repo to Railway
2. Railway auto-detects Go and builds with `go build`
3. Add a PostgreSQL plugin — `DATABASE_URL` is injected automatically
4. Set remaining env vars in Railway dashboard
5. Deploy

---

## Development

```bash
make dev        # run with hot reload (air)
make migrate    # run all pending migrations
make test       # run tests
make lint       # golangci-lint
make build      # production binary
```

### Testing

Each domain has its own test file. Services accept injected dependencies so tests run without real Postgres, Redis, Bridge, or Sui:

```go
service := NewDepositRouteService(DepositRouteDeps{
    Bridge:      &mockBridgeClient{},
    BridgeStore: &mockBridgeStore{},
    RouteStore:  &mockRouteStore{},
    WalletStore: &mockWalletStore{},
})
```

---

## Hackathon Scope vs Production

| Feature | Hackathon | Production |
|---|---|---|
| Auth fidelity | Stub device integrity verifier | Real App Attest + Play Integrity |
| AVS operators | 5 keys in-process | 5 independent signer microservices |
| Nearby discovery | Backend session only (no BLE) | BLE + Nearby Connections via mobile app |
| Nearby Assist | Deferred | Blind encrypted relay |
| Bridge KYC | Sandbox | Production KYB required |
| SuiNS | Testnet | Mainnet + custody contract |
| Gasless payments | User-paid fallback | Gasless USDsui when Sui Mainnet enables it |

---

## Architecture Reference

Full architecture documentation is in `/architecture/`:

- `001` — Code organization and request flow
- `002` — Auth model (OAuth, zkLogin, device integrity, local peer handshake)
- `003` — AVS authorization boundary
- `004` — SuiNS custodial profiles and leaf names
- `005` — Deposit routes (Bridge integration)
- `006` — Radar proximity protocol
- `007` — Nearby Assist blind relay
- `008` — Monitoring and observability
- `009` — Transaction funding (gasless / sponsored / user-paid)
- `010` — Mobile app architecture

---

## Built for Sui Overflow 2026

Track: DeFi & Payments

Team: Peter Anyaogu, Joel Emmanuel
