# Prover backend (the heavy proving container) with the proving key baked in.
#
# Baking the ~1GB zkey into the image means each cold start loads it from local disk instead of
# downloading a network volume — the difference between a tolerable cold start and a terrible one.
#
# Build context = tools/zkprover/  (so the zkey at zkeys/zkLogin-main.zkey is in scope).
# Run ./download-zkey.sh first to fetch the key.
FROM mysten/zklogin:prover-stable

COPY zkeys/zkLogin-main.zkey /app/binaries/zkLogin.zkey

ENV ZKEY=/app/binaries/zkLogin.zkey \
    WITNESS_BINARIES=/app/binaries
