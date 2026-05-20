package utils

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
)

func SHA256Hex(data []byte) string {
	h := sha256.Sum256(data)
	return hex.EncodeToString(h[:])
}

func SHA256HexString(s string) string {
	return SHA256Hex([]byte(s))
}

func HMACSHA256(key, data []byte) []byte {
	h := hmac.New(sha256.New, key)
	h.Write(data)
	return h.Sum(nil)
}

func HMACSHA256Hex(key []byte, data string) string {
	return hex.EncodeToString(HMACSHA256(key, []byte(data)))
}

func Base64URLEncode(data []byte) string {
	return base64.RawURLEncoding.EncodeToString(data)
}

func Base64URLDecode(s string) ([]byte, error) {
	return base64.RawURLEncoding.DecodeString(s)
}

func HexDecode(s string) ([]byte, error) {
	return hex.DecodeString(s)
}

func HexEncode(b []byte) string {
	return hex.EncodeToString(b)
}
