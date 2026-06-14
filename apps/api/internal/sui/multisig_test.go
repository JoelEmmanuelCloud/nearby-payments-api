package sui

import (
	"encoding/hex"
	"testing"
)

func TestBlake2b256KnownVector(t *testing.T) {
	got := hex.EncodeToString(blake2b256(nil))
	want := "0e5751c026e543b2e8ab2eb06099daa1d1e5df47778f7787faab45cdf12fe3a8"
	if got != want {
		t.Fatalf("blake2b256(empty) = %s, want %s", got, want)
	}
}

// TestBuildMultisigAddressCanonical pins the address derivation to Sui's canonical scheme using the
// production operator public keys (3-of-5). The prior implementation produced a phantom address
// (0xab29354d…) that no real multisig matches; the canonical address is 0xa29e8837….
func TestBuildMultisigAddressCanonical(t *testing.T) {
	pubHexes := []string{
		"b5158171784bd170ed830e89044c1c3f23cc671eaeabb9b6317df9643fd59092",
		"9b4e21cdc8ce36aee33bbfb4f763d229d4435d94ff53e69b603a4ad3d8dc8d54",
		"aa33707e4ae105688bcb18a4a9fe0610502dd923ff5f41a786de2697049ca98a",
		"2ef9ea0054e19d4556d25cd303fc153539c3e76ade4c602d00a5ea14db7d1951",
		"804f3120a998c61e0aaba699e2dcc4ec459f9bfa963311a0c8d9b5111e7471ee",
	}
	pubKeys := make([][]byte, len(pubHexes))
	for i, h := range pubHexes {
		b, err := hex.DecodeString(h)
		if err != nil {
			t.Fatalf("decode pubkey %d: %v", i, err)
		}
		pubKeys[i] = b
	}

	got := BuildMultisigAddress(pubKeys, 3)
	want := "0xa29e8837a510ecb86e5db516df07917f6c0390ea241700ad7e9ad727364d6e0d"
	if got != want {
		t.Fatalf("BuildMultisigAddress = %s, want canonical %s", got, want)
	}
}

func TestTransactionSigningDigest(t *testing.T) {
	txBytes := []byte{0x01, 0x02, 0x03, 0x04}

	got := TransactionSigningDigest(txBytes)
	if len(got) != 32 {
		t.Fatalf("digest length = %d, want 32", len(got))
	}

	want := blake2b256(append([]byte{0x00, 0x00, 0x00}, txBytes...))
	if hex.EncodeToString(got) != hex.EncodeToString(want) {
		t.Fatalf("digest = %x, want %x", got, want)
	}
}
