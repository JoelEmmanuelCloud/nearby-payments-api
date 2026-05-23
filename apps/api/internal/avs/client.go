package avs

import (
	"encoding/json"
	"fmt"
	"strings"

	"github.com/vaariance/nearby/internal/utils"
)

type Client struct {
	aggregator *Aggregator
}

func NewClient(operatorKeyHexList []string) (*Client, error) {
	const numOperators = 5
	const threshold = 3

	operators := make([]*Operator, numOperators)

	if len(operatorKeyHexList) == numOperators {
		for i, keyHex := range operatorKeyHexList {
			op, err := loadOperator(fmt.Sprintf("operator-%d", i+1), strings.TrimSpace(keyHex))
			if err != nil {
				return nil, fmt.Errorf("load operator %d: %w", i+1, err)
			}
			operators[i] = op
		}
	} else {
		for i := 0; i < numOperators; i++ {
			op, err := generateOperator(fmt.Sprintf("operator-%d", i+1))
			if err != nil {
				return nil, fmt.Errorf("generate operator %d: %w", i+1, err)
			}
			operators[i] = op
		}
	}

	signerSetID := utils.NewID()
	agg := newAggregator(operators, threshold, signerSetID)

	return &Client{aggregator: agg}, nil
}

func (c *Client) AuthorizeLeafRegistration(input LeafRegistrationInput) (*AuthorizeResult, error) {
	if input.Label == "" || input.UserAddress == "" || input.ParentName == "" {
		return nil, ErrInvalidPayload
	}

	payload := map[string]string{
		"label":             input.Label,
		"parentName":        input.ParentName,
		"leafName":          input.LeafName,
		"userAddress":       input.UserAddress,
		"walletBindingHash": input.WalletBindingHash,
	}
	payloadJSON, err := json.Marshal(payload)
	if err != nil {
		return nil, fmt.Errorf("marshal payload: %w", err)
	}
	payloadHash := "0x" + utils.SHA256Hex(payloadJSON)

	nonce, err := utils.RandomHex(16)
	if err != nil {
		return nil, fmt.Errorf("generate nonce: %w", err)
	}

	expiresAtMs := utils.NowUnixMs() + 5*60*1000

	sigs, err := c.aggregator.Authorize(ActionLeafRegisterInitial, payloadHash, nonce, expiresAtMs)
	if err != nil {
		return nil, err
	}

	signerIDs := make([]string, len(sigs))
	for i, s := range sigs {
		signerIDs[i] = s.OperatorID
	}

	return &AuthorizeResult{
		Status: "authorized",
		Authorization: &Authorization{
			Version:     1,
			Action:      ActionLeafRegisterInitial,
			PayloadHash: payloadHash,
			Nonce:       nonce,
			ExpiresAtMs: expiresAtMs,
			SignerSetID: c.aggregator.SignerSetID(),
			Signers:     signerIDs,
			Signatures:  sigs,
		},
	}, nil
}

func (c *Client) AuthorizeParentRenewal(targetPackage, targetObject string) (*AuthorizeResult, error) {
	payload := map[string]string{
		"targetPackage": targetPackage,
		"targetObject":  targetObject,
	}
	payloadJSON, _ := json.Marshal(payload)
	payloadHash := "0x" + utils.SHA256Hex(payloadJSON)

	nonce, err := utils.RandomHex(16)
	if err != nil {
		return nil, fmt.Errorf("generate nonce: %w", err)
	}

	expiresAtMs := utils.NowUnixMs() + 5*60*1000

	sigs, err := c.aggregator.Authorize(ActionParentRenew, payloadHash, nonce, expiresAtMs)
	if err != nil {
		return nil, err
	}

	signerIDs := make([]string, len(sigs))
	for i, s := range sigs {
		signerIDs[i] = s.OperatorID
	}

	return &AuthorizeResult{
		Status: "authorized",
		Authorization: &Authorization{
			Version:     1,
			Action:      ActionParentRenew,
			PayloadHash: payloadHash,
			Nonce:       nonce,
			ExpiresAtMs: expiresAtMs,
			SignerSetID: c.aggregator.SignerSetID(),
			Signers:     signerIDs,
			Signatures:  sigs,
		},
	}, nil
}

func (c *Client) ApproveSponsorTx(txBytesHash string) (*AuthorizeResult, error) {
	payload := map[string]string{
		"transactionBytesHash": txBytesHash,
	}
	payloadJSON, _ := json.Marshal(payload)
	payloadHash := "0x" + utils.SHA256Hex(payloadJSON)

	nonce, err := utils.RandomHex(16)
	if err != nil {
		return nil, fmt.Errorf("generate nonce: %w", err)
	}

	expiresAtMs := utils.NowUnixMs() + 2*60*1000

	sigs, err := c.aggregator.Authorize(ActionSponsorTxApprove, payloadHash, nonce, expiresAtMs)
	if err != nil {
		return nil, err
	}

	signerIDs := make([]string, len(sigs))
	for i, s := range sigs {
		signerIDs[i] = s.OperatorID
	}

	return &AuthorizeResult{
		Status: "authorized",
		Authorization: &Authorization{
			Version:     1,
			Action:      ActionSponsorTxApprove,
			PayloadHash: payloadHash,
			Nonce:       nonce,
			ExpiresAtMs: expiresAtMs,
			SignerSetID: c.aggregator.SignerSetID(),
			Signers:     signerIDs,
			Signatures:  sigs,
		},
	}, nil
}

func (c *Client) SignerSetInfo() SignerSetInfo {
	return SignerSetInfo{
		ID:         c.aggregator.SignerSetID(),
		PublicKeys: c.aggregator.PublicKeys(),
		Threshold:  3,
	}
}
