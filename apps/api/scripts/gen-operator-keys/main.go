package main

import (
	"crypto/ed25519"
	"crypto/rand"
	"encoding/base64"
	"encoding/hex"
	"fmt"
	"strings"

	"golang.org/x/crypto/blake2b"
)

const (
	ed25519Flag  byte = 0x00
	multisigFlag byte = 0x03
	numOperators      = 5
	threshold    uint16 = 3
)

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
	h, _ := blake2b.New256(nil)
	h.Write(data)
	return h.Sum(nil)
}

func buildMultisigAddress(publicKeys [][]byte, threshold uint16) string {
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
	return "0x" + hex.EncodeToString(hash)
}

func main() {
	type key struct {
		hexPriv string
		pubKey  []byte
	}

	keys := make([]key, numOperators)
	publicKeys := make([][]byte, numOperators)

	for i := 0; i < numOperators; i++ {
		pub, priv, err := ed25519.GenerateKey(rand.Reader)
		if err != nil {
			panic(err)
		}
		keys[i] = key{
			hexPriv: hex.EncodeToString(priv),
			pubKey:  pub,
		}
		publicKeys[i] = pub
	}

	multisigAddr := buildMultisigAddress(publicKeys, threshold)

	fmt.Println("=== AVS Operator Keys ===")
	fmt.Println()

	hexKeys := make([]string, numOperators)
	for i, k := range keys {
		hexKeys[i] = k.hexPriv
	}
	fmt.Printf("AVS_OPERATOR_KEYS=%s\n", strings.Join(hexKeys, ","))
	fmt.Println()

	fmt.Println("=== Multisig Sponsor Address ===")
	fmt.Println()
	fmt.Printf("Address: %s\n", multisigAddr)
	fmt.Printf("Threshold: %d of %d\n", threshold, numOperators)
	fmt.Println()

	fmt.Println("=== Sui CLI Verification ===")
	fmt.Println()
	fmt.Println("Import keys into Sui keytool:")
	for i, k := range keys {
		seed := k.hexPriv[:64]
		seedBytes, _ := hex.DecodeString(seed)
		suiKeyPair := append([]byte{ed25519Flag}, seedBytes...)
		suiKeyPairB64 := base64.StdEncoding.EncodeToString(suiKeyPair)
		fmt.Printf("  operator-%d: sui keytool import %s ed25519\n", i+1, suiKeyPairB64)
	}
	fmt.Println()

	fmt.Println("Generate and verify multisig address:")
	pks := make([]string, numOperators)
	for i, k := range keys {
		suiPub := append([]byte{ed25519Flag}, k.pubKey...)
		pks[i] = base64.StdEncoding.EncodeToString(suiPub)
	}
	weights := strings.Repeat("1 ", numOperators)
	fmt.Printf("  sui keytool multi-sig-address --pks %s --weights %s--threshold %d\n",
		strings.Join(pks, " "),
		weights,
		threshold,
	)
	fmt.Println()
	fmt.Printf("Expected address: %s\n", multisigAddr)
}
