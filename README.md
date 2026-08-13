# Nearby Payments

A hybrid fintech app that lets people discover each other via device proximity, verify payment identity through SuiNS, and settle peer payments on the [Sui](https://sui.io) blockchain — funded by USD deposits via Bridge virtual accounts and crypto liquidation addresses.

Built for **Sui Overflow 2026** (Track: DeFi & Payments) by [Peter Anyaogu](https://github.com/vaariance) and [Joel Emmanuel](https://github.com/JoelEmmanuelCloud).

## Monorepo Layout

Bazel-managed monorepo covering the backend and both native mobile clients:

```
apps/
  api/        Go backend — auth, deposits, payments, SuiNS names, nearby sessions
  android/    Android app (Kotlin) + BLE/Nearby Connections bridge module
  ios/        iOS app (SwiftUI)

packages/
  ui/         Shared Swift UI components (Button, Card, Text, Toast)

docs/
  architecture/   Numbered design docs — auth model, AVS boundary, deposit routes,
                   proximity protocol, transaction funding, mobile app architecture
```

## Backend

The Go API (Chi, PostgreSQL, Redis, Sui via `sui-go-sdk`) is the most complete piece of the stack — full route list, auth fidelity model, AVS multisig design, Bridge fiat onramp integration, database schema, and local setup are documented in **[`apps/api/README.md`](./apps/api/README.md)**.

## Architecture Docs

Full design rationale for each subsystem lives in [`docs/architecture/`](./docs/architecture/), including the auth model (OAuth, zkLogin, device integrity), the AVS authorization boundary, SuiNS custodial profiles, the proximity/BLE protocol, and gasless transaction funding.

## Status

Built during Sui Overflow 2026. The backend runs end-to-end against Sui testnet and Bridge's sandbox; see `apps/api/README.md` for what's stubbed for the hackathon versus what a production deployment would swap in (real device attestation, independent AVS operator services, mainnet SuiNS).
