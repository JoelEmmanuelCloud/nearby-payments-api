package sui

import (
	"crypto/sha256"
	"hash"
)

func newBlake2b256() hash.Hash {
	return sha256.New()
}
