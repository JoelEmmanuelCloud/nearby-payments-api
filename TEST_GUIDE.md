# Nearby Payments API — Test Guide

## Environments

| | Base URL |
|---|---|
| **Local** | `http://localhost:8080` |
| **Production** | `https://nearby-api-565533426961.us-central1.run.app` |

The Postman collection variable `{{baseUrl}}` defaults to production. To test locally, set it to `http://localhost:8080` in the collection **Variables** tab. `{{localUrl}}` is pre-set to the local value as a convenience.

**Run the local server:**
```
cd apps/api
go run ./cmd/api/main.go
```
Confirm it is up: `GET {{baseUrl}}/health` → `{"status":"ok"}`

---

## Auth Levels

Every protected endpoint uses one of two auth levels:

| Level | What it checks |
|-------|----------------|
| **low** | Valid Bearer token only |
| **high** | Bearer token + `X-Device-Provider`, `X-Request-Nonce`, `X-Request-Timestamp` headers. Nonce must be unique (replay protection via Redis). Timestamp must be within 5 minutes of now. |

The Postman pre-request scripts on `high` endpoints generate these headers automatically.

---

## Step 1 — Get an Access Token

1. Open `{{baseUrl}}/static/auth_test.html` in your browser
2. Select platform (`ios` or `android`) and click **Sign in with Google**
3. Complete Google sign-in — the page redirects back and completes the exchange automatically
4. Copy the **Access Token** from the green box

Paste the token into the Postman collection variable `accessToken`:
- Click the collection name → **Variables** tab → set `accessToken` current value

All requests using `Authorization: Bearer {{accessToken}}` will now authenticate.

**What sign-in creates:**
- A `users` row
- A `sessions` row (access + refresh tokens)
- A `devices` and `device_integrity_records` row

> Wallet binding is no longer part of sign-in. After completing OAuth, call `PUT /v1/me/wallet` with the derived `suiAddress` to bind the wallet (see Step 4). Deposit endpoints require a wallet binding.

**Token TTLs:**
- Access token: 15 minutes
- Refresh token: 30 days

---

## Step 2 — Health & Public Key

No auth required.

### Health Check
```
GET /health
```
Expected: `200 {"status":"ok"}`

### Get Server Public Key
```
GET /v1/auth/server-public-key
```
Expected: `200` with the server's ed25519 public key. Mobile clients use this to verify credential signatures.

---

## Step 3 — Auth Endpoints

### OAuth Begin
No auth required. Returns a `state` token (and an `authURL` for web flow) that must be passed to OAuth Complete.

**Web flow** (browser PKCE):
```
POST /v1/auth/oauth/begin
Body:
{
  "provider": "google",
  "flowType": "web",
  "codeChallenge": "<SHA256(codeVerifier), base64url-encoded>",
  "codeChallengeMethod": "S256",
  "zkLoginNonce": "<ephemeral public key nonce>"
}
```
Expected: `200` — redirect the user to `authURL`. Google returns `code` + `state` to the redirect URI.

**Native flow** (iOS / Android SDK — already has `idToken`):
```
POST /v1/auth/oauth/begin
Body:
{
  "provider": "google",
  "flowType": "native",
  "zkLoginNonce": "<ephemeral public key nonce>"
}
```
Expected: `200` — only `state` is returned. `authURL` is omitted; the native SDK handles sign-in.

> `flowType` defaults to `"web"` if omitted.

---

### OAuth Complete
No auth required. Exchanges credentials for an access token, refresh token, JWT, and zkLogin salt.

**Web flow:**
```
POST /v1/auth/oauth/complete
Body:
{
  "flowType": "web",
  "code": "<authorization code from Google redirect>",
  "state": "<state from oauth/begin>",
  "codeVerifier": "<original PKCE secret>",
  "platform": "ios",
  "osVersion": "18.0",
  "appBundleId": "com.nearby.app",
  "deviceIntegrity": { "provider": "stub" }
}
```

**Native flow:**
```
POST /v1/auth/oauth/complete
Body:
{
  "flowType": "native",
  "idToken": "<id_token from Google SDK>",
  "state": "<state from oauth/begin>",
  "authorizationCode": "<optional, iOS only>",
  "platform": "ios",
  "osVersion": "18.0",
  "appBundleId": "com.nearby.app",
  "deviceIntegrity": {
    "provider": "apple_dcapp_attest",
    "keyId": "<key id>",
    "assertion": "<assertion>",
    "clientDataHash": "<client data hash>"
  }
}
```

Expected: `200`
```json
{
  "accessToken": "...",
  "refreshToken": "...",
  "expiresAt": 1234567890,
  "refreshExpiresAt": 1234567890,
  "userId": "...",
  "jwt": "<google id token>",
  "salt": "<zklogin salt hex>"
}
```

> `state` is required for both flows (CSRF protection). After receiving `jwt` and `salt`, compute `suiAddress = jwtToAddress(jwt, salt)` using the Sui SDK, then call `PUT /v1/me/wallet` to bind it.

---

### Refresh Session
Auth level: **low**

The `refreshToken` variable is auto-populated after sign-in. Send as-is — the test script saves the new tokens automatically.

```
POST /v1/auth/refresh
Body: { "refreshToken": "{{refreshToken}}" }
```
Expected: `200` with new `accessToken` and `refreshToken`

> Each refresh token is single-use. After a successful refresh the old token is invalid. Update `accessToken` in collection variables if you use it again.

### Revoke Session
Auth level: **low**

Signs out the current session; the access token becomes invalid immediately.

```
POST /v1/auth/revoke
```
Expected: `204 No Content`

After revoking, sign in again via the browser page to get a fresh token.

### Assert Device Integrity
Auth level: **high** (headers auto-generated by pre-request script)

Used by mobile clients after attestation. In testing, `provider: stub` bypasses real attestation.

```
POST /v1/auth/integrity
Body:
{
  "deviceIntegrity": { "provider": "stub", "keyId": "" },
  "timestampMs": {{$timestamp}}000
}
```
Expected: `204 No Content`

### Issue Device Credential
Auth level: **high** (headers auto-generated)

Issues a signed ed25519 credential tied to the device's local proof key.

```
POST /v1/auth/credential
Body: { "localProofPublicKey": "0x0000000000000000000000000000000000000000000000000000000000000001" }
```
Expected: `200` with a signed `DeviceIdentityCredential` object containing a `signature` field.

---

## Step 4 — Me (Profile, Avatar & Wallet)

Auth level: **low** for all endpoints.

### Bind Wallet
Binds a zkLogin-derived Sui address to the authenticated user. Must be called after OAuth Complete once the client has computed `suiAddress = jwtToAddress(jwt, salt)` using the Sui SDK.

```
PUT /v1/me/wallet
Body: { "suiAddress": "0x<64 hex chars>" }
```
Expected: `204 No Content`

Re-calling with a different address updates the binding (upsert). Required before deposit endpoints will work.

### Get Profile
```
GET /v1/me/profile
```
Expected: `200`
```json
{
  "userId": "...",
  "status": "active",
  "avatarUrl": "https://aggregator.walrus-testnet.walrus.space/v1/blobs/...",
  "createdAt": 1234567890
}
```
`avatarUrl` is omitted if no avatar has been uploaded yet.

### Upload Avatar
Uploads a profile picture to Walrus decentralized storage and stores the blob ID.

```
PUT /v1/me/avatar
Content-Type: image/jpeg   (or image/png, image/webp, image/gif)
Body: <binary image data>
```

**In Postman:**
1. Set the `Content-Type` header to match your image type
2. In the **Body** tab select **binary** and choose an image file from disk
3. Send

Expected: `200`
```json
{ "avatarUrl": "https://aggregator.walrus-testnet.walrus.space/v1/blobs/..." }
```

After uploading, `GET /v1/me/profile` returns `avatarUrl` with the same URL.

**Constraints:**
- Max file size: 5 MB
- Accepted types: `image/jpeg`, `image/png`, `image/webp`, `image/gif`
- Returns `415` for unsupported content types
- Returns `413` for files over 5 MB

---

## Step 5 — Deposit Endpoints

All deposit endpoints require **low** auth and a wallet binding. Call `PUT /v1/me/wallet` after sign-in to create the binding before using these endpoints.

If you get `422 Unprocessable Entity`, the wallet binding is missing — call `PUT /v1/me/wallet` with a valid Sui address.

### Get Deposit Options
```
GET /v1/deposit/options
```
Expected: `200` — response shape depends on KYC status:

**First call (KYC not started):**
```json
{
  "fiatUsd": {
    "kind": "kyc_required",
    "bridgeKycLinkId": "...",
    "kycUrl": "https://bridge.withpersona.com/verify?...",
    "tosUrl": "https://compliance.sandbox.bridge.xyz/accept-terms-of-service?...",
    "status": "not_started"
  },
  "crypto": {
    "kind": "deposit_addresses",
    "routes": []
  }
}
```

**After KYC approved:**
```json
{
  "fiatUsd": {
    "kind": "account_details",
    "account": {
      "id": "...",
      "currency": "usd",
      "rails": ["ach_push", "wire"],
      "bankName": "...",
      "accountNumberLast4": "...",
      "routingNumber": "...",
      "accountHolderName": "..."
    }
  },
  "crypto": {
    "kind": "deposit_addresses",
    "routes": [
      { "rail": "evm", "currency": "usdc", "address": "0x..." },
      { "rail": "solana", "currency": "usdc", "address": "..." },
      { "rail": "solana", "currency": "usdt", "address": "..." }
    ]
  }
}
```

> Complete KYC by visiting the `kycUrl` from the first call. Use the Bridge sandbox test identity to approve quickly.

### Get Deposit History
```
GET /v1/deposit/history?limit=20&offset=0
```
Expected: `200` with a list of deposits (empty array if none yet). `limit` and `offset` are optional.

### Get Deposit by ID
Set `depositId` collection variable to an ID from the history response.

```
GET /v1/deposit/{{depositId}}
```
Expected: `200` with deposit details, or `404` if the ID doesn't exist / belongs to another user.

---

## Step 6 — Payment Endpoints

### Create Payment Intent
Auth level: **high** (headers + idempotency key auto-generated by pre-request script)

```
POST /v1/payments/intents
Headers: Idempotency-Key: <auto-generated>
Body:
{
  "recipientAddress": "0x0000000000000000000000000000000000000000000000000000000000000002",
  "recipientName": "alice@nearby.sui",
  "asset": "USDsui",
  "amountAtomic": "1000000",
  "fundingMode": "sponsored",
  "idempotencyKey": "<copy value from Idempotency-Key header>"
}
```

**Before sending:** copy the value that the pre-request script sets for `Idempotency-Key` header into the body field `idempotencyKey`. Both must match.

**Constraints:**
- `asset` must be `"USDsui"`
- `recipientAddress` must be `0x` + 64 hex characters (66 chars total)
- `amountAtomic` is in micro-units (`"1000000"` = 1 USDsui)
- `fundingMode`: `"sponsored"` (server pays gas) or `"user_paid"` (user pays gas)
- Intent expires in **2 minutes** — submit or cancel before then

Expected: `201` — test script saves `intentId` to `{{intentId}}`

Resending with the same `Idempotency-Key` returns `409 idempotent_replay`.

### Get Payment Intent
Auth level: **low**

```
GET /v1/payments/intents/{{intentId}}
```
Expected: `200` with current `status` (`pending`, `submitted`, `cancelled`, `failed`)

### Cancel Payment Intent
Auth level: **low** — only works while intent is `pending`

```
POST /v1/payments/intents/{{intentId}}/cancel
```
Expected: `204 No Content`

### Submit Payment Intent
Auth level: **low** — requires a real Sui transaction built and signed by the mobile app

```
POST /v1/payments/intents/{{intentId}}/submit
Body:
{
  "txBytes": "<base64-encoded Sui transaction bytes>",
  "userSignature": "<Sui signature>"
}
```
Expected: `200` with `paymentId`, `txDigest`, `status: "confirmed"`

### Get Payment by ID
Auth level: **low**

```
GET /v1/payments/{{paymentId}}
```
Expected: `200` with full payment details including `txDigest` and `confirmedAt`

---

## Step 7 — Names Endpoints

Both require **high** auth (headers auto-generated).

### Register Leaf Name
Registers an on-chain SuiNS name (e.g. `alice.nearby`). Registration is async — returns a task ID.

```
POST /v1/names/leaf
Body: { "leafName": "alice" }
```
Expected: `202 Accepted` with `taskId` — test script saves it to `{{taskId}}`

> Triggers a real on-chain transaction. Requires SuiNS configuration in `.env`.

### Get Name Task
Poll to check registration status.

```
GET /v1/names/tasks/{{taskId}}
```
Expected: `200` with `status` (`pending`, `confirmed`, `failed`)

---

## Step 8 — Nearby Sessions

All three require **high** auth (headers auto-generated).

### Initiate Session
Sender opens a proximity payment session targeting a recipient Sui address.

```
POST /v1/nearby/sessions
Body:
{
  "recipientSuiAddress": "0x0000000000000000000000000000000000000000000000000000000000000002",
  "payloadType": "payment_request",
  "payloadData": "{\"amount\": \"1000000\"}"
}
```
Expected: `201` — test script saves `id` to `{{sessionId}}`

### Get Session
```
GET /v1/nearby/sessions/{{sessionId}}
```
Expected: `200` with session status and payload

### Acknowledge Session
Recipient accepts or rejects.

```
POST /v1/nearby/sessions/{{sessionId}}/acknowledge
Body: { "accept": true }
```
Expected: `200`

---

## Step 9 — Webhooks

### Bridge Webhook

Called by Bridge when a fiat deposit arrives. Not user-triggered.

```
POST /v1/webhooks/bridge
Headers:
  Content-Type: application/json
  X-Bridge-Signature: <RSA-SHA256 signature, base64-encoded>
Body: { "id": "...", "type": "virtual_account.activity", "data": {} }
```

**Signature format:** Bridge signs the raw request body with their RSA private key using PKCS1v15 + SHA256. The server verifies with the configured `BRIDGE_WEBHOOK_PUBLIC_KEY`.

You cannot generate a valid signature without Bridge's private key. To test this endpoint:
- Use the **Send Test Webhook** feature in the [Bridge sandbox dashboard](https://dashboard.bridge.xyz)
- Or trigger a real deposit event through the sandbox

The unit test suite (`webhook_test.go`) validates the full signature flow with a generated key pair — run it with:
```
cd apps/api
go test ./internal/domain/deposit/... -run TestHandleBridgeWebhook -v
```

---

## Common Error Responses

| Status | Code | Cause |
|--------|------|-------|
| 400 | `bad_request` | Malformed JSON body |
| 400 | `validation_error` | Missing required field |
| 400 | `idempotency_key_required` | Missing `Idempotency-Key` header on payment intents |
| 400 | `asset_unsupported` | Asset is not `USDsui` |
| 400 | `invalid_address` | Recipient address not 66 chars or not `0x`-prefixed |
| 401 | `unauthorized` | Missing or invalid Bearer token |
| 401 | `webhook_signature_invalid` | Missing or incorrect `X-Bridge-Signature` |
| 401 | `high_fidelity_required` | Missing `X-Device-Provider`, `X-Request-Nonce`, or `X-Request-Timestamp` |
| 401 | `timestamp_out_of_window` | Timestamp more than 5 minutes old |
| 401 | `replay_detected` | Nonce already used |
| 404 | `not_found` | Resource doesn't exist or belongs to another user |
| 409 | `idempotent_replay` | `Idempotency-Key` already used within 24 hours |
| 413 | `payload_too_large` | Avatar image exceeds 5 MB |
| 415 | `unsupported_media_type` | Avatar content type not jpeg/png/webp/gif |
| 422 | `unprocessable` | Wallet binding missing — sign in again |
| 503 | `bridge_unavailable` | Bridge API returned an error |
| 500 | `internal_error` | Database or external service error |

---

## Recommended Test Sequence

```
1.  Health Check
2.  Get Server Public Key
3.  OAuth Begin (Web or Native)     (get state; web also returns authURL)
4.  Sign in via browser / SDK      (web: paste accessToken into Postman; native: use OAuth Complete directly)
5.  Bind Wallet                     (PUT /v1/me/wallet with suiAddress derived from jwt + salt)
6.  Get Profile                     (no avatarUrl yet)
7.  Upload Avatar                   (set Content-Type + binary body in Postman)
8.  Get Profile                     (avatarUrl now present)
9.  Get Deposit Options             (confirms wallet binding; expect kyc_required on first call)
10. Get Deposit History             (empty array expected)
11. Create Payment Intent           (copy Idempotency-Key header value into body field)
12. Get Payment Intent              (status: pending)
13. Cancel Payment Intent           (status → cancelled)
14. Create another Payment Intent   (new Idempotency-Key auto-generated)
15. Get Payment Intent              (status: pending)
16. Refresh Session                 (new tokens saved automatically)
17. Assert Device Integrity
18. Issue Device Credential
19. Initiate Nearby Session
20. Get Nearby Session
21. Acknowledge Nearby Session
22. Register Leaf Name              (requires SuiNS config)
23. Get Name Task                   (poll until confirmed)
24. Revoke Session
```
