package sui

import (
	"hash"

	"golang.org/x/crypto/blake2b"
)

func newBlake2b256() hash.Hash {
	h, _ := blake2b.New256(nil)
	return h
}
