package avs

import (
	"crypto/ed25519"
	"crypto/rand"
	"encoding/hex"
	"fmt"
)

type Operator struct {
	id         string
	privateKey ed25519.PrivateKey
	publicKey  ed25519.PublicKey
}

func newOperator(id string, privateKey ed25519.PrivateKey) *Operator {
	return &Operator{
		id:         id,
		privateKey: privateKey,
		publicKey:  privateKey.Public().(ed25519.PublicKey),
	}
}

func generateOperator(id string) (*Operator, error) {
	pub, priv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		return nil, fmt.Errorf("generate operator key: %w", err)
	}
	return &Operator{
		id:        id,
		privateKey: priv,
		publicKey:  pub,
	}, nil
}

func loadOperator(id, hexPrivKey string) (*Operator, error) {
	privBytes, err := hex.DecodeString(hexPrivKey)
	if err != nil {
		return nil, fmt.Errorf("decode operator key %s: %w", id, err)
	}
	if len(privBytes) != ed25519.PrivateKeySize {
		return nil, fmt.Errorf("operator key %s has wrong length: %d", id, len(privBytes))
	}
	priv := ed25519.PrivateKey(privBytes)
	return &Operator{
		id:        id,
		privateKey: priv,
		publicKey:  priv.Public().(ed25519.PublicKey),
	}, nil
}

func (o *Operator) Sign(payload []byte) (OperatorSignature, error) {
	sig := ed25519.Sign(o.privateKey, payload)
	return OperatorSignature{
		OperatorID: o.id,
		PublicKey:  o.publicKey,
		Signature:  sig,
	}, nil
}

func (o *Operator) PublicKeyBytes() []byte {
	return []byte(o.publicKey)
}

func (o *Operator) ID() string {
	return o.id
}
