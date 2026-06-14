# KYC Flow — Bridge Integration

## Overview

KYC (Know Your Customer) is required before a user can receive crypto or fiat deposits. Bridge handles identity verification via Persona. The backend does not run identity checks itself — it delegates entirely to Bridge and checks Bridge's customer status on demand.

---

## User-Facing Flow

### Step 1 — Initiate KYC

The mobile app calls:

```
GET /v1/deposit/options
Authorization: Bearer <accessToken>
```

If the user has no Bridge customer yet, the backend creates one via Bridge's KYC link API and returns:

```json
{
  "fiatUsd": {
    "kind": "kyc_required",
    "bridgeKycLinkId": "9fd61106-db52-43ad-9a64-e431529e0289",
    "kycUrl": "https://bridge.withpersona.com/verify?...",
    "tosUrl": "https://compliance.sandbox.bridge.xyz/accept-terms-of-service?...",
    "status": "not_started"
  },
  "crypto": { "kind": "deposit_addresses", "routes": [] }
}
```

The app must open **both** URLs for the user:
- `kycUrl` — Persona-hosted identity verification (government ID, selfie)
- `tosUrl` — Bridge terms of service acceptance

Both must be completed before Bridge will issue deposit addresses. They can be shown in sequence: TOS first, then KYC, or as two separate steps in the onboarding screen.

### Step 2 — User Completes KYC and Accepts TOS

These flows are entirely hosted by Bridge/Persona. The user leaves the app (or uses a WebView) to complete them. The backend is not involved during this step.

### Step 3 — Check Status

The app polls `GET /v1/deposit/options` to detect when KYC is done. The `fiatUsd.kind` field tells the app what state to show:

| `fiatUsd.kind` | `status` value | What to show |
|---|---|---|
| `kyc_required` | `not_started` | "Start verification" — open kycUrl + tosUrl |
| `kyc_required` | `rejected` | "Verification failed" — user can retry via kycUrl |
| `kyc_pending` | `under_review` | "Under review" — check back later |
| `kyc_pending` | `awaiting_questionnaire` | "Action required" — open kycUrl |
| `kyc_pending` | `awaiting_ubo` | "Action required" — open kycUrl |
| `account_details` | — | KYC approved — show bank account details for fiat deposits |

When `kind` is `account_details`, the user is fully approved and can receive both fiat and crypto deposits.

### Step 4 — Request Deposit Addresses

Once KYC is approved, the app can call:

```
POST /v1/deposit/liquidation-address
Authorization: Bearer <accessToken>
Content-Type: application/json

{ "network": "base", "currency": "usdc" }
```

The backend checks Bridge eligibility before creating any address. If KYC is not yet approved it returns `403 kyc_not_approved` instead of attempting to create an address.

---

## How the Backend Knows KYC Status

The backend **does not receive push notifications from Bridge for KYC events**. Status is checked on demand every time the user calls `GET /v1/deposit/options`.

The call chain is:

```
GET /v1/deposit/options
  → store.GetBridgeLinkByUserID       (get Bridge customer ID from DB)
  → bridge.GetCustomerEligibility     (GET /v0/customers/{id} on Bridge API)
      └─ returns kyc_status + endorsements
  → if approved + endorsed → bridge.EnsureVirtualAccount
  → if not → return kyc_required or kyc_pending state
```

Bridge's customer record contains:
- `kyc_status`: `not_started` | `under_review` | `awaiting_questionnaire` | `awaiting_ubo` | `approved` | `rejected`
- `endorsements[].name == "base"` with `status == "approved"` — required for crypto and fiat deposits
- `has_accepted_terms_of_service`: boolean — must be `true` before any deposit address is issued
- `capabilities.payin_crypto`: `pending` | `active` — active only when both KYC and TOS are done

The backend uses `kyc_status == "approved"` AND `endorsement "base" status == "approved"` as the gate. Bridge only marks the endorsement approved after both identity verification and TOS acceptance are complete.

---

## Webhooks

Bridge sends webhook events to `POST /v1/webhooks/bridge` for deposit activity (payments received, transfers settled). The handler:

1. Verifies the RSA signature using `BRIDGE_WEBHOOK_PUBLIC_KEY`
2. Checks for duplicate events (idempotency)
3. Stores the raw event in the `bridge_webhook_events` table

**KYC status changes are not handled via webhook today.** The `bridge_webhook_events` table stores all incoming events for audit and future processing, but there is no background worker that reads them. KYC state is always fetched live from Bridge when the user calls `GET /v1/deposit/options`.

If a background KYC notification system is added later, it would read from `bridge_webhook_events` where `processed = false` and `event_type` matches Bridge's KYC event types (e.g. `kyc.approved`, `kyc.rejected`).

---

## Rejection

If Bridge rejects a user's KYC (e.g. document mismatch, sanctions hit), the next call to `GET /v1/deposit/options` returns:

```json
{
  "fiatUsd": {
    "kind": "kyc_required",
    "kycUrl": "https://bridge.withpersona.com/verify?...",
    "tosUrl": "...",
    "status": "rejected"
  }
}
```

The app should show an error state with the option to retry. The same `kycUrl` can be used to re-submit. Bridge decides whether to allow re-submission based on their internal policy.

---

## Summary Diagram

```
Mobile App                    Backend                      Bridge
    │                             │                            │
    ├─ GET /deposit/options ──────►│                            │
    │                             ├─ GET /v0/customers/{id} ──►│
    │                             │◄── kyc_status: not_started ┤
    │◄── kind: kyc_required ──────┤                            │
    │                             │                            │
    ├─ open kycUrl in WebView ────────────────────────────────►│
    ├─ open tosUrl in WebView ────────────────────────────────►│
    │   (user completes both)                                  │
    │                             │                            │
    ├─ GET /deposit/options ──────►│                            │
    │  (poll until approved)      ├─ GET /v0/customers/{id} ──►│
    │                             │◄── kyc_status: approved ───┤
    │◄── kind: account_details ───┤                            │
    │                             │                            │
    ├─ POST /deposit/             │                            │
    │    liquidation-address ─────►│                            │
    │                             ├─ GetCustomerEligibility ──►│
    │                             │◄── approved ───────────────┤
    │                             ├─ POST liquidation_addresses►│
    │◄── { address, minAmount } ──┤◄── address ────────────────┤
```
