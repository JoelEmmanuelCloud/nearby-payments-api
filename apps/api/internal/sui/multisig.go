package sui

import (
	"crypto/ed25519"
	"encoding/base64"
)

const (
	ed25519Flag  byte = 0x00
	multisigFlag byte = 0x03
)

func BuildMultisigAddress(publicKeys [][]byte, threshold uint16) string {
	var payload []byte
	payload = append(payload, multisigFlag)
	payload = appendULEB128(payload, uint64(len(publicKeys)))

	for _, pk := range publicKeys {
		payload = append(payload, ed25519Flag)
		payload = append(payload, pk...)
		payload = append(payload, 1)
	}

	payload = append(payload, byte(threshold), byte(threshold>>8))

	hash := blake2b256(payload)
	return "0x" + hexEncode(hash)
}

func CombineMultisigSignature(publicKeys [][]byte, signatures [][]byte, threshold uint16, bitmap uint16) string {
	var payload []byte

	payload = appendULEB128(payload, uint64(len(signatures)))
	for _, sig := range signatures {
		payload = append(payload, ed25519Flag)
		payload = append(payload, sig...)
	}

	payload = append(payload, byte(bitmap), byte(bitmap>>8))

	payload = appendULEB128(payload, uint64(len(publicKeys)))
	for _, pk := range publicKeys {
		payload = append(payload, ed25519Flag)
		payload = append(payload, pk...)
		payload = append(payload, 1)
	}
	payload = append(payload, byte(threshold), byte(threshold>>8))

	envelope := append([]byte{multisigFlag}, payload...)
	return base64.StdEncoding.EncodeToString(envelope)
}

func SignBytes(privKey ed25519.PrivateKey, txBytes []byte) string {
	sig := ed25519.Sign(privKey, txBytes)
	pubKey := privKey.Public().(ed25519.PublicKey)

	var envelope []byte
	envelope = append(envelope, ed25519Flag)
	envelope = append(envelope, sig...)
	envelope = append(envelope, pubKey...)

	return base64.StdEncoding.EncodeToString(envelope)
}

func appendULEB128(buf []byte, v uint64) []byte {
	for {
		b := byte(v & 0x7f)
		v >>= 7
		if v != 0 {
			b |= 0x80
		}
		buf = append(buf, b)
		if v == 0 {
			break
		}
	}
	return buf
}

func blake2b256(data []byte) []byte {
	h := newBlake2b256()
	h.Write(data)
	return h.Sum(nil)
}

func hexEncode(b []byte) string {
	const hexChars = "0123456789abcdef"
	dst := make([]byte, len(b)*2)
	for i, v := range b {
		dst[i*2] = hexChars[v>>4]
		dst[i*2+1] = hexChars[v&0x0f]
	}
	return string(dst)
}
