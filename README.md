# Nearby Payments

A mobile-first, peer-to-peer payment system built on the Sui blockchain. Users discover nearby peers via Bluetooth and local radio protocols, verify identity locally, and exchange USDsui without requiring an internet connection on both sides. When one peer is offline, an encrypted relay (Nearby Assist) bridges the gap without exposing payment contents to the routing device.

The backend is a minimal Go control plane — handling auth, session management, deposit orchestration, and gas sponsorship. Crypto custody, profile ownership, and transaction signing authority always remain with users and on-chain contracts.

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Repository Structure](#repository-structure)
- [Backend API](#backend-api)
  - [Tech Stack](#tech-stack)
  - [Domain Structure](#domain-structure)
  - [API Routes](#api-routes)
  - [Authentication](#authentication)
  - [AVS Authorization](#avs-authorization)
- [Mobile Apps](#mobile-apps)
  - [Shared Swift Packages](#shared-swift-packages)
  - [iOS](#ios)
  - [Android](#android)
- [On-Chain Contracts](#on-chain-contracts)
- [Core Protocols](#core-protocols)
  - [Radar — Local Discovery](#radar--local-discovery)
  - [Nearby Assist — Offline Relay](#nearby-assist--offline-relay)
- [Deposit Routes](#deposit-routes)
- [Transaction Funding](#transaction-funding)
- [Local Development](#local-development)
- [Deployment](#deployment)
- [Environment Variables](#environment-variables)
- [Testing](#testing)

---

## Architecture Overview

The system is documented across eleven architecture specs in [`architecture/architecture/`](architecture/architecture/). Each spec defines strict, non-overlapping responsibilities:

| Spec | Topic |
|------|-------|
| 001  | Backend code organisation and domain layering |
| 002  | Multi-fidelity authentication and device integrity |
| 003  | AVS operator quorum and multisig sponsorship |
| 004  | Custodial profiles — SuiNS names and Walrus storage |
| 005  | Deposit routes — fiat (Bridge virtual accounts) and crypto (liquidation addresses) |
| 006  | Radar protocol — BLE/Nearby Connections local discovery |
| 007  | Nearby Assist — encrypted offline relay |
| 008  | Notifications, observability, and anomaly monitoring |
| 009  | Transaction funding modes — gasless, sponsored, user-paid |
| 010  | Mobile app architecture — Swift/Kotlin shared core |
| 011  | KYC flow — Bridge/Persona identity verification |

**Key design principle:** The backend is never in the payment hot path. Local peer verification, transaction signing, and Sui submission all happen on device. The backend is involved only when a user needs to register a name, fund a deposit route, refresh a session, or orchestrate sponsored gas.

---

## Repository Structure

```
nearby-payments-api/
├── apps/
│   ├── api/                    # Go backend (Cloud Run)
│   │   ├── cmd/api/            # Entry point
│   │   ├── internal/
│   │   │   ├── avs/            # AVS aggregator, operator client, multisig
│   │   │   ├── config/         # Environment-based configuration
│   │   │   ├── db/             # Migrations, PostgreSQL, Redis clients
│   │   │   ├── domain/
│   │   │   │   ├── auth/       # OAuth, sessions, device integrity, zkLogin
│   │   │   │   ├── deposit/    # Bridge virtual accounts, liquidation addresses, webhooks
│   │   │   │   ├── names/      # SuiNS leaf registration tasks
│   │   │   │   ├── nearby/     # Radar sessions, Nearby Assist relay
│   │   │   │   └── payment/    # Payment intents and finalized payment records
│   │   │   ├── errors/         # Typed AppError with machine-readable codes
│   │   │   ├── middleware/     # Auth enforcement, idempotency, rate limiting, logging
│   │   │   ├── sui/            # Sui JSON-RPC client, BCS encoder, multisig derivation
│   │   │   ├── utils/          # ULID generation, time helpers, crypto utilities
│   │   │   └── walrus/         # Walrus blob storage client
│   │   ├── router/             # Chi router wiring and middleware chain
│   │   ├── static/             # Static files served by the API
│   │   ├── Dockerfile
│   │   ├── Makefile
│   │   └── go.mod
│   ├── android/                # Kotlin/Compose Android app
│   └── ios/                    # SwiftUI iOS app
├── contracts/
│   └── names/                  # Move custody contract (SuiNS leaf ownership)
│       ├── sources/
│       │   └── custody.move
│       ├── Move.toml
│       └── Published.toml
├── packages/                   # Shared Swift packages (iOS + Android via bindings)
│   ├── auth/                   # OAuth, session, device integrity abstraction
│   ├── device-integrity/       # iOS App Attest / Android Play Integrity
│   ├── gateway/                # Typed backend API client
│   ├── hsm/                    # HSM-safe key material handling
│   ├── identity/               # User identity and profile models
│   ├── storage/                # Keychain/Keystore secure storage abstraction
│   ├── sui/                    # Lean Sui API client
│   ├── sui-api/                # GraphQL Sui API operations
│   ├── sui-bcs/                # BCS encoding for Sui Move calls
│   ├── ui/                     # Design system (SwiftUI + Compose)
│   └── workspace/              # Build and test orchestration
├── architecture/               # Architecture decision documents (001–011)
├── docs/                       # Additional documentation
├── cloudbuild.yaml             # Google Cloud Build pipeline
└── MODULE.bazel                # Bazel monorepo configuration
```

---

## Backend API

### Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | Go 1.25 |
| Router | [chi v5](https://github.com/go-chi/chi) |
| Database | PostgreSQL via [pgx v5](https://github.com/jackc/pgx) |
| Cache / Rate Limiting | Redis via [go-redis v9](https://github.com/redis/go-redis) |
| ID Generation | [ULID v2](https://github.com/oklog/ulid) |
| Cryptography | `golang.org/x/crypto` — Ed25519, Blake2b |
| Google Cloud | `google.golang.org/api` — KMS, Secret Manager, Cloud Run |
| Observability | OpenTelemetry (tracing), structured JSON logs to stdout |
| Container | Alpine 3.21 multistage Docker build |
| Runtime | Google Cloud Run (managed, us-central1) |

### Domain Structure

Each domain follows the same four-layer pattern:

```
handler.go   — HTTP request parsing, response serialisation
service.go   — Business logic, orchestration, cross-domain calls
store.go     — Database queries (pgx), Redis operations
types.go     — Domain models, request/response structs, error codes
```

Domains never import each other directly. Cross-domain calls go through the service layer only, and only when strictly necessary.

### API Routes

All routes are prefixed with `/v1`.

**Health**

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Liveness probe — returns `{"status":"ok"}` |

**Auth**

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/auth/server-public-key` | None | Get backend encryption public key |
| POST | `/auth/oauth/begin` | None | Initiate OAuth with PKCE challenge |
| POST | `/auth/oauth/complete` | None | Finalize OAuth, create user/device/session |
| POST | `/auth/oauth/callback/apple` | None | Apple OAuth callback handler |
| POST | `/auth/zklogin/prove` | Low | Submit zkLogin proof for wallet binding |
| POST | `/auth/refresh` | High | Rotate access token (device integrity required) |
| POST | `/auth/revoke` | Low | Revoke current session |
| POST | `/auth/integrity` | Low | Assert device integrity proof (App Attest / Play Integrity) |
| POST | `/auth/credential` | High | Issue portable device credential for local peer auth |

**Deposits**

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/deposit/options` | Low | Get fiat and crypto deposit state (discriminated union) |
| GET | `/deposit/history` | Low | List deposit history |
| GET | `/deposit/{id}` | Low | Get single deposit record |
| POST | `/deposit/liquidation-address` | High | Create crypto deposit address (EVM or Solana) |
| POST | `/webhooks/bridge` | Signed | Ingest Bridge payment event webhooks |

**Payments**

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/payments/intents` | High + Idempotency-Key | Create payment intent |
| GET | `/payments/intents/{id}` | Low | Get payment intent status |
| POST | `/payments/intents/{id}/submit` | High | Submit signed Sui transaction |
| POST | `/payments/intents/{id}/cancel` | High | Cancel pending intent |
| GET | `/payments/{id}` | Low | Get finalised payment record |

**Names (SuiNS)**

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/names/leaf/{leafName}/available` | None | Check if a name label is available |
| POST | `/names/leaf` | High | Request AVS authorisation for initial leaf registration |
| POST | `/names/tasks/{id}/submit` | High | Submit the registration transaction digest |
| GET | `/names/tasks/{id}` | Low | Poll registration task status |

**Profile**

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/me/profile` | Low | Get current user's profile (SuiNS name, address, avatar pointer) |
| PUT | `/me/avatar` | High | Upload avatar blob to Walrus |
| PUT | `/me/wallet` | High | Bind Sui address to current session |

**Nearby**

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/nearby/sessions` | High | Create radar session (local discovery) |
| GET | `/nearby/sessions/{id}` | Low | Get radar session state |
| POST | `/nearby/sessions/{id}/acknowledge` | High | Acknowledge a verified local peer |
| POST | `/assist/relay` | Blind | Forward encrypted packet on behalf of an offline device |

### Authentication

The API uses three authentication fidelity levels. Each builds on the previous.

**Low Fidelity**
- Valid access token (opaque, 15-minute TTL)
- Active session record in the database
- Active device record bound to the session
- Used for: read endpoints, session revocation

**High Fidelity**
- Everything in Low, plus:
- Platform device integrity proof bound to the request body hash, nonce, and timestamp
  - iOS: App Attest assertion with sign-counter increment
  - Android: Play Integrity token with `requestHash` binding, app/device verdict check
- Strict replay detection (nonce indexed per device)
- Used for: payment intents, name registration, session refresh, credential issuance, deposit address creation

**Blind Fidelity**
- Applies to `/assist/relay` only
- Outer: The routing (assistant) device presents its own low-fidelity session
- Inner: The ciphertext envelope contains the offline (assisted) device's session proof and platform integrity assertion
- Backend decrypts using the server private key (HPKE X25519 + AESGCM256) and re-verifies sender identity
- The routing device cannot read the payload

**Session Model**
- Tokens are opaque random bytes — not JWTs
- Stored in the database as hashes; the raw token is never persisted
- Session is bound to a specific device; cannot be transferred
- Revocation is a synchronous database flag flip
- Refresh requires high-fidelity auth (device integrity proof)

**Device Credentials (Local Auth)**
- Server-signed credentials (Ed25519) issued after high-fidelity auth
- Carry: user ID, device ID, SuiNS name, Sui address, integrity provider, local proof public key, capabilities
- TTL: 24 hours
- Used exclusively for offline local peer verification — the backend is not in the verification path
- Peers verify the server signature and cross-check the claimed SuiNS name against on-chain resolution

### AVS Authorization

Certain protocol-sensitive actions require a 3-of-5 operator quorum before they proceed. In V1 this is implemented as a deterministic Sui multisig address, not a full EigenLayer AVS.

**Quorum Configuration**
- 5 independent signer microservices on separate infrastructure
- Threshold: 3 of 5 (tolerates 2 failures or compromises)
- Keys: Ed25519 / Secp256k1 / Secp256r1 (Sui-compatible), weight 1 each
- The multisig address is derived once from the 5 public keys and is deterministic

**AVS-Authorized Actions**
| Action | Description |
|--------|-------------|
| `leaf_name.register_initial` | Initial SuiNS leaf registration — requires AVS + user signature |
| `sponsor_tx.approve` | Gas sponsorship for bounded protocol flows |
| `parent_name.renew` | Renew the protocol-owned parent SuiNS name |
| `parent_name.admin_recover` | Emergency parent name recovery |

**AVS-Forbidden Actions**
- Updating or revoking a user's leaf name (user-signed only, no AVS override)
- Signing arbitrary transactions
- Any action outside the explicit domain-separated allowlist

**Authorization Paths**
- Synchronous: Service requests authorisation → aggregator collects partial signatures from 5 operators → first valid 3-of-5 combination returned → service proceeds in the same request
- Asynchronous: Service receives a pending task ID → background worker polls completion → worker updates state when quorum is reached

---

## Mobile Apps

### Shared Swift Packages

Protocol logic, cryptography, state machines, and typed models are implemented as pure Swift packages under `packages/`. This shared core is consumed natively by iOS and via Swift-Java bindings on Android.

| Package | Purpose |
|---------|---------|
| `auth` | OAuth flows, session management, device integrity orchestration |
| `device-integrity` | Platform abstraction over iOS App Attest and Android Play Integrity |
| `gateway` | Typed, generated backend API client |
| `hsm` | HSM-safe handling of key material (Secure Enclave / StrongBox) |
| `identity` | User identity models, device credential parsing and verification |
| `storage` | Unified Keychain (iOS) / Keystore (Android) secure storage interface |
| `sui` | Lean Sui JSON-RPC / GraphQL client — balances, transactions, events |
| `sui-api` | Typed GraphQL operations for Sui network queries |
| `sui-bcs` | BCS encoder for composing Sui Move call transactions |
| `ui` | Shared design system — SwiftUI components (iOS) and Compose equivalents (Android) |
| `workspace` | Bazel build and test orchestration for the monorepo |

### iOS

- **Language:** Swift 6.3
- **UI:** SwiftUI
- **Discovery:** Core Bluetooth (BLE central/peripheral) + Network.framework (local transport)
- **Device Integrity:** App Attest (`DCAppAttestService`) with sign-counter tracking
- **Secure Storage:** Keychain Services via the `storage` package
- **Wallet:** zkLogin — ephemeral keypair lives in the Secure Enclave; no backend key custody
- **Offline Visibility:** ActivityKit Live Activity / Dynamic Island shows relay status

### Android

- **Language:** Kotlin
- **UI:** Jetpack Compose
- **Discovery:** Google Nearby Connections API (primary), BLE (fallback), Wi-Fi Aware (where available)
- **Device Integrity:** Play Integrity API with `requestHash` binding
- **Secure Storage:** Android Keystore via the `storage` package
- **Wallet:** zkLogin — ephemeral keypair in StrongBox / TEE
- **Offline Visibility:** Foreground service notification shows relay status

---

## On-Chain Contracts

### Names Custody Contract (`contracts/names/`)

A Move contract deployed on Sui that holds the protocol-owned parent SuiNS name capability and authorises leaf subname registration.

**Key responsibilities:**
- Hold the `ParentCap` (SuiNS parent capability) on behalf of the protocol
- Accept leaf registration calls that carry a valid AVS multisig authorisation
- Verify the authorisation payload: action type, label, user address, nonce, expiry
- Transfer leaf ownership to the user's Sui address after verification
- Emit events for indexers and monitoring

**Trust model:** The AVS multisig address is embedded in the contract at deployment. A user cannot register a leaf without both their own signature and 3-of-5 AVS signatures. The contract verifies both on-chain — the backend cannot forge either.

**SuiNS name structure:**
```
nearby.sui                   ← Protocol-owned parent, held by custody contract
alice@nearby.sui             ← User-owned leaf, registered via the contract
```

---

## Core Protocols

### Radar — Local Discovery

Radar is the local discovery and payment protocol. The backend is entirely absent from the discovery and verification path.

**Protocol layers (bottom to top):**

1. **Radio** — BLE advertisements (iOS), Nearby Connections (Android)
2. **Transport** — Platform-native local link (GATT / Network.framework / Wi-Fi Aware)
3. **Handshake** — SYN/ACK with ephemeral key exchange and nonce binding

```
Sender  →  Receiver:  SYN  (protocol_version, sessionId, nonce, ephemeral_pubkey, device_credential)
Receiver →  Sender:   ACK  (synHash, nonce, ephemeral_pubkey, device_credential, local_transcript_sig)
Both derive:  X25519(ephemeral_private, peer_ephemeral_public) → HKDF → AEAD session key
```

4. **Peer Verification** — Nine sequential checks before a peer's name is displayed:
   - Device credential signature verifies against server public key
   - Credential is not expired (TTL ~24 hours)
   - Credential grants the `nearby_payments` capability
   - Credential SuiNS name matches the advertised name
   - Credential Sui address matches the advertised address
   - SuiNS resolves the advertised name to the advertised address (on-chain check)
   - App Attest / Play Integrity assertion verifies against the credential's local proof public key
   - Integrity challenge equals the local transcript hash
   - Peer nonce is fresh (not replayed)

5. **Payment** — Sender composes amount, signs with zkLogin ephemeral key, submits to Sui directly

**Discovery reliability notes:**
- Both apps in foreground: highest reliability
- One app backgrounded: best-effort, OS-dependent
- Both backgrounded: opportunistic only
- Fallback: QR code (address + name, no radio required)

### Nearby Assist — Offline Relay

Nearby Assist lets an offline device (no internet) send payments through a nearby peer that has connectivity. The routing peer (assistant) cannot read the payment contents.

**Capability negotiation:**
```
Assisted  →  Assistant:  AssistSyn  (protocol, session, nonce, requested_routes)
Assistant →  Assisted:   AssistAck  (capability, credential, transcript_sig, relay_encryption_key)
Assisted verifies: assistant credential is valid, assistant has internet, assistant is willing to relay
```

**Relay packet flow:**
1. Assisted device encrypts the backend request body to the server public key (HPKE X25519 + AESGCM256)
2. AAD includes: route, session ID, sequence number, nonce, timestamps, sender integrity proof
3. Packet sent over the local link to the assistant
4. Assistant forwards the ciphertext unchanged to `POST /v1/assist/relay`
5. Backend decrypts, verifies the inner session, verifies the sender's platform integrity proof
6. Backend returns an encrypted response; assistant forwards it unchanged
7. Assisted device decrypts and processes the response

**Allowed relay routes:** `payment.submit`, `session.refresh`, `deposit.options`, `name.register`

**Assistant UI obligation:** The assistant device must display a visible "relaying a nearby payment" indicator (Live Activity on iOS, foreground service on Android). The copy must clearly state the contents are encrypted and the amounts are not visible to the assistant.

---

## Deposit Routes

Users can fund their Sui wallet through two independent channels.

### Fiat USD — Bridge Virtual Accounts

Requires KYC completion via Persona (Bridge-hosted). Status progresses through:

```
not_started  →  under_review  →  approved
```

When `approved` and the base endorsement is active, the response includes ACH Push and Wire rails with account details. The backend polls Bridge live on every `GET /deposit/options` call — there is no webhook-driven KYC state machine.

### Crypto — Liquidation Addresses

No KYC required. Supported networks:

| Network | Assets |
|---------|--------|
| Ethereum | USDC |
| Base | USDC |
| Polygon | USDC |
| Arbitrum | USDC |
| Optimism | USDC |
| Avalanche C-Chain | USDC |
| Solana | USDC, USDT |

All crypto deposits are delivered to the user's Sui address as USDsui via Bridge's cross-chain routing.

### Response Shape

Both channels return strict discriminated unions — no nullable fields for state-critical data:

```typescript
{
  fiatUsd:
    | { kind: 'kyc_required';    bridgeKycLinkId: string; kycUrl: string; tosUrl: string; status: string }
    | { kind: 'kyc_pending';     bridgeKycLinkId: string; status: string }
    | { kind: 'account_details'; account: { id; currency; rails[]; bankName; accountNumberLast4; ... } }

  crypto:
    | { kind: 'deposit_addresses'; routes: [{ rail; currency; address; supportedChains[] }] }
}
```

---

## Transaction Funding

Three funding modes, applied in priority order:

| Mode | Who pays gas | When used |
|------|-------------|-----------|
| Gasless USDsui | Sui protocol | When Sui enables gasless stablecoin transfers (Mainnet, future) |
| Sponsored | Protocol AVS multisig | Protocol-initiated flows: SuiNS registration, leaf updates, approved payment actions |
| User-paid | User's SUI balance | Fallback; always available |

The sponsorship middleware enforces an explicit allowlist of sponsorable action types, requires high-fidelity auth, requires an idempotency key, and applies rate-limit and risk policy before returning a sponsor signature. It never mutates the user's transaction payload.

---

## Local Development

### Prerequisites

- Go 1.25+
- PostgreSQL 15+
- Redis 7+
- [air](https://github.com/air-verse/air) (hot reload)
- [golangci-lint](https://golangci-lint.run/) (linting)

### Setup

```bash
# Clone and enter the repo
git clone https://github.com/vaariance/nearby.git
cd nearby

# Install Go dependencies
cd apps/api
make setup

# Copy and populate environment variables
cp .env.example .env
# Edit .env with your DATABASE_URL, REDIS_URL, and API keys

# Run with hot reload
make dev
```

The server starts on port `8080` by default. Database migrations run automatically on startup.

### Makefile Targets (apps/api/)

| Target | Description |
|--------|-------------|
| `make setup` | Run `go mod tidy` |
| `make dev` | Start server with `air` hot reload |
| `make build` | Compile binary to `bin/api` |
| `make test` | Run all tests (`go test ./...`) |
| `make lint` | Run `golangci-lint` |

---

## Deployment

The API is deployed to Google Cloud Run in `us-central1`. There is no automatic build trigger — deploys are manual via Cloud Build.

**Deploy command (PowerShell):**
```powershell
$sha = (git rev-parse HEAD).Trim()
gcloud builds submit --config cloudbuild.yaml --substitutions COMMIT_SHA=$sha .
```

**Build pipeline (`cloudbuild.yaml`):**
1. Build Docker image from `apps/api/Dockerfile` (multistage: Go 1.25 builder → Alpine 3.21 runtime)
2. Tag image with `$COMMIT_SHA` and `latest`
3. Push both tags to Artifact Registry (`us-central1-docker.pkg.dev/nearby-496718/nearby/nearby-api`)
4. Deploy the `$COMMIT_SHA`-tagged image to the `nearby-api` Cloud Run service

**Live endpoint:** `https://nearby-api-nry2jzv3qq-uc.a.run.app`

**Health check:** `GET /health` → `{"status":"ok"}`

**Database migrations** run on application startup via `internal/db/migrate.go`. Each migration file runs exactly once, tracked by filename in a `schema_migrations` table.

---

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | Yes | PostgreSQL connection string |
| `REDIS_URL` | Yes | Redis connection string |
| `PORT` | No | HTTP listen port (default: 8080) |
| `ENV` | Yes | `development` or `production` |
| `BRIDGE_API_KEY` | Yes | Bridge API key for deposit and KYC routes |
| `BRIDGE_WEBHOOK_PUBLIC_KEY` | Yes | RSA public key for Bridge webhook signature verification |
| `APPLE_CLIENT_ID` | Yes | Apple OAuth client ID |
| `APPLE_TEAM_ID` | Yes | Apple Developer team ID (App Attest verification) |
| `GOOGLE_CLIENT_ID` | Yes | Google OAuth client ID |
| `SUI_RPC_URL` | No | Sui JSON-RPC endpoint (defaults to testnet) |
| `CREDENTIAL_SIGNING_KEY` | Yes | Ed25519 private key for device credential issuance |
| `AVS_AGGREGATOR_URL` | Yes | Internal AVS aggregator endpoint |
| `WALRUS_ENDPOINT` | No | Walrus storage endpoint |
| `SUINS_PACKAGE_ID` | Yes | On-chain SuiNS package object ID |
| `CUSTODY_CONTRACT_ID` | Yes | On-chain names custody contract object ID |

In production, secrets are sourced from Google Cloud Secret Manager. In development, a local `.env` file is loaded via `godotenv`.

---

## Testing

Tests are colocated with the code they test (`*_test.go` files alongside each package).

**Test layers:**

| Layer | What is tested |
|-------|----------------|
| Schemas / Types | Payload validation rejects malformed input; strict field checks |
| Handlers | Auth middleware enforcement, HTTP status codes, response shapes |
| Services | Business logic, state transitions, error propagation |
| Stores | SQL query correctness, pagination, deduplication |
| Webhooks | Signature verification, event deduplication, edge cases |
| Sui client | BCS encoding, multisig derivation, transaction construction |
| Integration | End-to-end flows: OAuth → session → payment intent → submit |

```bash
cd apps/api
make test          # run all tests
go test ./internal/domain/auth/... -v   # run a specific domain
```

**Coverage note:** Integration tests connect to a real PostgreSQL and Redis instance. Set `DATABASE_URL` and `REDIS_URL` in your environment before running them. No in-memory mocks are used for persistence — the test suite is designed to catch schema/query divergence early.
