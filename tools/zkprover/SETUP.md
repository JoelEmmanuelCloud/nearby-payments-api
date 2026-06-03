# zkLogin Prover — Local Setup

This runs the Mysten Labs zkLogin prover on your machine so the Nearby Payments API can generate ZK proofs locally instead of calling the hosted service.

**Requirements:** Docker Desktop, 16 GB RAM minimum (32 GB recommended), ~2 GB free disk space.

---

## Step 1 — Download the proving key

The prover needs a ~1 GB cryptographic key file. This is a one-time download.

Open **Git Bash** or **WSL** inside the `zklogin/` folder and run:

```bash
bash download-zkey.sh
```

This creates `zklogin/zkeys/zkLogin-main.zkey`. Do not delete or move this file.

To verify the download completed correctly, run:

```bash
b2sum zkeys/zkLogin-main.zkey
```

The hash should match the value published at:
https://github.com/sui-foundation/zklogin-ceremony-contributions

---

## Step 2 — Create your .env file

Inside the `zklogin/` folder, copy the example file:

```bash
cp .env.example .env
```

The default works as-is:

```
PROVER_PORT=8003
```

`PROVER_PORT` is the port your machine exposes the prover on. Change it if 8003 is already in use.

---

## Step 3 — Start the prover

From the `zklogin/` folder:

```bash
docker compose up
```

Docker pulls two images on first run (`mysten/zklogin:prover-stable` and `mysten/zklogin:prover-fe-stable`). Subsequent starts are fast.

You should see output from both the `backend` and `frontend` containers. The prover is ready when the `frontend` container logs show it is listening.

To run in the background:

```bash
docker compose up -d
```

To stop:

```bash
docker compose down
```

---

## Step 4 — Verify the prover is running

```bash
curl http://localhost:8003/ping
```

Expected response:

```
pong
```

If you get `Connection refused`, the containers are still starting. Wait a few seconds and try again.

---

## Step 5 — Point the API at your local prover

In the `apps/api/.env` file (the backend's env file), add or update:

```
ZKLOGIN_PROVER_URL=http://localhost:8003/v1
```

Restart the API server. It will now send all proof requests to your local prover instead of the Mysten-hosted service.

To switch back to the hosted prover, remove `ZKLOGIN_PROVER_URL` from the API env file (the default is `https://prover.mystenlabs.com/v1`).

---

## Step 6 — Test an end-to-end proof request

With both the prover and API running, send a test request to the backend:

```bash
curl -X POST http://localhost:8080/v1/auth/zklogin/prove \
  -H "Content-Type: application/json" \
  -d '{
    "jwt": "<google_id_token>",
    "extendedEphemeralPublicKey": "<eph_pub_key>",
    "maxEpoch": 10,
    "jwtRandomness": "<randomness>",
    "salt": "<user_salt>",
    "keyClaimName": "sub"
  }'
```

A successful response is a JSON object containing the ZK proof fields (`proofPoints`, `issBase64Details`, `headerBase64`). This proof is passed directly to `getZkLoginSignature` on the client.

---

## How this fits the auth flow

```
1. Client generates ephemeral key pair + randomness, computes zkLogin nonce
2. POST /v1/auth/oauth/begin  →  gets Google auth URL (nonce embedded)
3. User signs in with Google  →  client receives authorization code
4. POST /v1/auth/oauth/complete  →  backend returns { jwt, salt, accessToken, ... }
5. POST /v1/auth/zklogin/prove  →  backend proxies to prover, returns ZK proof
6. Client uses ephemeral key + proof to sign Sui transactions via getZkLoginSignature
```

Steps 1–4 use the live backend on Cloud Run. Step 5 hits your local prover when `ZKLOGIN_PROVER_URL` is set to `http://localhost:8003/v1`.

---

## Troubleshooting

**Proof generation times out**
The prover is CPU-intensive. First proof after startup is slowest. If it consistently times out, check Docker Desktop's resource allocation — give it at least 8 CPUs and 16 GB RAM under Settings → Resources.

**`pong` works but proof requests fail**
Make sure the `backend` container (not just the `frontend`) is healthy. Run `docker compose logs backend` to check for errors.

**Port conflict**
Change `PROVER_PORT` in your `.env` to any free port and update `ZKLOGIN_PROVER_URL` in the API env file to match.

**zkey file not found**
The volume mount expects the file at `zklogin/zkeys/zkLogin-main.zkey`. Make sure `download-zkey.sh` completed successfully and the file exists at that path.
