# zkLogin Prover on Cloud Run (scale-to-zero, $0 idle)

Self-hosts the Mysten zkLogin prover on Cloud Run instead of a paid service. `minScale: 0` ⇒ **no
cost when idle**; you pay only while a proof is running (~$0.001–0.002/proof). The trade-off is a
**cold start** on the first proof after idle (pull image + load the ~1GB zkey ≈ 30–90s) — covered by
the app's existing post-login proof **warm-up**, so it lands in the background, not in front of a user.

Architecture mirrors `../docker-compose.yml` as one Cloud Run service with two containers:
`prover-fe` (ingress, `/ping` + `/v1`) → `prover` sidecar (heavy, baked zkey).

## Prereqs
- `gcloud` authed to your project; `docker` running.
- A GCP project with billing; Artifact Registry + Cloud Run APIs enabled.
- The backend's service account email (it will be the only invoker). Call it `BACKEND_SA`.

## Deploy
```bash
cd tools/zkprover
./download-zkey.sh                      # one-time: fetches zkeys/zkLogin-main.zkey (~1GB)
PROJECT=your-proj REGION=us-central1 \
  BACKEND_SA=api@your-proj.iam.gserviceaccount.com \
  ./gcp/deploy.sh
```
The script builds the baked-zkey image, deploys the multi-container service **private**, grants the
backend SA `run.invoker`, and prints the URL.

## Wire it up (path A — backend-proxied, private prover)
1. **Backend:** set `ZKLOGIN_PROVER_URL=<service-url>/v1` (the backend already proxies via
   `POST /v1/auth/zklogin/prove`, and injects the user salt). Its service account must be `BACKEND_SA`.
2. **App:** point `RemoteZkProofService` at the backend's prove endpoint
   (`<api-base>/v1/auth/zklogin/prove`) instead of `AppConstants.remoteZkProverURL`. The app then stops
   sending salt (backend owns it). *(This is the small final code step.)*

The prover stays unreachable publicly — no cost-abuse vector.

## Verify
```bash
URL=$(gcloud run services describe zklogin-prover --region us-central1 --format='value(status.url)')
curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" "$URL/ping"   # -> pong
```
First call triggers a cold start; watch logs (`gcloud run services logs read zklogin-prover`) until the
`prover-fe` container reports listening and the `prover` sidecar finishes loading the zkey.

## Tuning notes (verify on first deploy)
- **Ports:** sidecars share localhost, so `prover-fe`=8082 (ingress), `prover`=8080. If the stock
  prover image doesn't bind `8080` as assumed, adjust `PROVER_URI`/ports in `service.yaml`.
- **Resources:** Cloud Run allows per-container CPU only from `{<1, 1, 2, 4, 6, 8}` (no 3/5/7) and the
  instance total (sum) must also be one of `{1,2,4,6,8}`. Current: `prover-fe` 2 vCPU/1Gi + `prover`
  6 vCPU/23Gi = 8 vCPU / 24Gi. Cheaper: `prover` 4 vCPU + `prover-fe` 2 = 6 total. Drop `prover` memory
  to 16Gi if it fits; raise if proofs OOM.
- **Cold start:** if it's ever unacceptable, set `minScale: 1` for one warm instance — but that breaks
  $0 idle. Stay at 0 until you scale.
- **Mainnet vs testnet zkey:** `download-zkey.sh` fetches the main (mainnet) ceremony key. Use the
  test zkey if you're proving against test JWKs.
