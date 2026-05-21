package avs

import (
	"crypto/ed25519"
	"encoding/json"
	"fmt"

	"github.com/vaariance/nearby/internal/utils"
)

type Aggregator struct {
	operators   []*Operator
	threshold   int
	signerSetID string
}

func newAggregator(operators []*Operator, threshold int, signerSetID string) *Aggregator {
	return &Aggregator{
		operators:   operators,
		threshold:   threshold,
		signerSetID: signerSetID,
	}
}

func (a *Aggregator) Authorize(action, payloadHash, nonce string, expiresAtMs int64) ([]OperatorSignature, error) {
	if !AllowedActions[action] {
		return nil, ErrActionForbidden
	}

	authPayload := AuthorizationPayload{
		Version:     1,
		Domain:      "nearby-payments.avs.authorization",
		Chain:       "sui:testnet",
		Action:      action,
		PayloadHash: payloadHash,
		Nonce:       nonce,
		IssuedAtMs:  utils.NowUnixMs(),
		ExpiresAtMs: expiresAtMs,
	}

	data, err := json.Marshal(authPayload)
	if err != nil {
		return nil, fmt.Errorf("marshal authorization payload: %w", err)
	}

	signingData := append([]byte("nearby-payments.avs.authorization"), data...)

	var collected []OperatorSignature
	for _, op := range a.operators {
		if len(collected) >= a.threshold {
			break
		}
		sig, err := op.Sign(signingData)
		if err != nil {
			continue
		}
		if !ed25519.Verify(op.publicKey, signingData, sig.Signature) {
			continue
		}
		collected = append(collected, sig)
	}

	if len(collected) < a.threshold {
		return nil, ErrQuorumNotMet
	}

	return collected[:a.threshold], nil
}

func (a *Aggregator) SignerSetID() string {
	return a.signerSetID
}

func (a *Aggregator) PublicKeys() [][]byte {
	keys := make([][]byte, len(a.operators))
	for i, op := range a.operators {
		keys[i] = op.PublicKeyBytes()
	}
	return keys
}
