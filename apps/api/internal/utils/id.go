package utils

import (
	"crypto/rand"
	"math/big"
	"time"

	"github.com/oklog/ulid/v2"
)

func NewID() string {
	entropy := ulid.Monotonic(rand.Reader, 0)
	return ulid.MustNew(ulid.Timestamp(time.Now()), entropy).String()
}

func NewToken() (string, error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return encodeHex(b), nil
}

func encodeHex(b []byte) string {
	const hexChars = "0123456789abcdef"
	dst := make([]byte, len(b)*2)
	for i, v := range b {
		dst[i*2] = hexChars[v>>4]
		dst[i*2+1] = hexChars[v&0x0f]
	}
	return string(dst)
}

func RandomHex(n int) (string, error) {
	b := make([]byte, n)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return encodeHex(b), nil
}

func RandomInt64() (int64, error) {
	n, err := rand.Int(rand.Reader, big.NewInt(1<<62))
	if err != nil {
		return 0, err
	}
	return n.Int64(), nil
}
