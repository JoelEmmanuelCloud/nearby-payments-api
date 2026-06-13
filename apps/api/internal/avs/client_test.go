package avs

import (
	"crypto/ed25519"
	"encoding/hex"
	"testing"
)

func TestSignSponsorTransactionProducesValidSuiSignatures(t *testing.T) {
	const numOperators = 5

	keys := make([]string, numOperators)
	for i := 0; i < numOperators; i++ {
		_, priv, err := ed25519.GenerateKey(nil)
		if err != nil {
			t.Fatalf("generate key %d: %v", i, err)
		}
		keys[i] = hex.EncodeToString(priv)
	}

	client, err := NewClient(keys)
	if err != nil {
		t.Fatalf("new client: %v", err)
	}

	digest := make([]byte, 32)
	for i := range digest {
		digest[i] = byte(i)
	}

	sigs, bitmap, err := client.SignSponsorTransaction(digest)
	if err != nil {
		t.Fatalf("sign sponsor tx: %v", err)
	}

	info := client.SignerSetInfo()
	if len(sigs) != info.Threshold {
		t.Fatalf("got %d signatures, want threshold %d", len(sigs), info.Threshold)
	}

	bitsSet := 0
	sigIdx := 0
	for i, pk := range info.PublicKeys {
		if bitmap&(1<<uint(i)) == 0 {
			continue
		}
		if !ed25519.Verify(ed25519.PublicKey(pk), digest, sigs[sigIdx]) {
			t.Fatalf("signature %d does not verify against operator %d over the digest", sigIdx, i)
		}
		bitsSet++
		sigIdx++
	}

	if bitsSet != info.Threshold {
		t.Fatalf("bitmap sets %d bits, want threshold %d", bitsSet, info.Threshold)
	}
}
