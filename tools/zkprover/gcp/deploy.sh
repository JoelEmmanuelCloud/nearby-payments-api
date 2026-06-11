#!/usr/bin/env bash
# Build the baked-zkey prover image and deploy the scale-to-zero Cloud Run service.
# Run from tools/zkprover/ :  PROJECT=my-proj REGION=us-central1 BACKEND_SA=api@my-proj.iam.gserviceaccount.com ./gcp/deploy.sh
set -euo pipefail

PROJECT="${PROJECT:?set PROJECT}"
REGION="${REGION:-us-central1}"
REPO="${REPO:-zklogin}"
SERVICE="${SERVICE:-zklogin-prover}"
IMAGE="${REGION}-docker.pkg.dev/${PROJECT}/${REPO}/prover-zkey:latest"

# 0. zkey must be present (baked into the image).
if [ ! -f zkeys/zkLogin-main.zkey ]; then
  echo "Missing zkeys/zkLogin-main.zkey — run ./download-zkey.sh first." >&2
  exit 1
fi

# 1. Artifact Registry repo (idempotent).
gcloud artifacts repositories create "$REPO" \
  --repository-format=docker --location="$REGION" --project="$PROJECT" 2>/dev/null || true
gcloud auth configure-docker "${REGION}-docker.pkg.dev" --quiet

# 2. Build + push the prover image (context = tools/zkprover, Dockerfile in gcp/).
docker build -f gcp/Dockerfile -t "$IMAGE" .
docker push "$IMAGE"

# 3. Deploy the multi-container service (private by default; backend invokes it).
sed -e "s|__IMAGE__|${IMAGE}|g" -e "s|__REGION__|${REGION}|g" gcp/service.yaml > /tmp/zklogin-prover.yaml
gcloud run services replace /tmp/zklogin-prover.yaml --project="$PROJECT" --region="$REGION"

# 4. Keep it PRIVATE; grant only the backend service account permission to invoke.
gcloud run services remove-iam-policy-binding "$SERVICE" \
  --member=allUsers --role=roles/run.invoker --project="$PROJECT" --region="$REGION" 2>/dev/null || true
if [ -n "${BACKEND_SA:-}" ]; then
  gcloud run services add-iam-policy-binding "$SERVICE" \
    --member="serviceAccount:${BACKEND_SA}" --role=roles/run.invoker \
    --project="$PROJECT" --region="$REGION"
fi

URL="$(gcloud run services describe "$SERVICE" --project="$PROJECT" --region="$REGION" --format='value(status.url)')"
echo
echo "Deployed: $URL"
echo "Set backend ZKLOGIN_PROVER_URL=${URL}/v1"
echo "Smoke test (needs an identity token):  curl -H \"Authorization: Bearer \$(gcloud auth print-identity-token)\" ${URL}/ping  -> pong"
