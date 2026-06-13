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
