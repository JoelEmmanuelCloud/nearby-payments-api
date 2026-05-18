package sui

import (
	"context"
	"encoding/base64"
	"fmt"

	"github.com/JoelEmmanuelCloud/nearby-payments-api/internal/avs"
)

type Sponsor struct {
	suiClient       *Client
	avsClient       *avs.Client
	sponsorAddress  string
	operatorPubKeys [][]byte
	threshold       uint16
}

func NewSponsor(suiClient *Client, avsClient *avs.Client) *Sponsor {
	info := avsClient.SignerSetInfo()
	address := BuildMultisigAddress(info.PublicKeys, uint16(info.Threshold))
	return &Sponsor{
		suiClient:       suiClient,
		avsClient:       avsClient,
		sponsorAddress:  address,
		operatorPubKeys: info.PublicKeys,
		threshold:       uint16(info.Threshold),
	}
}

func (s *Sponsor) Address() string {
	return s.sponsorAddress
}

func (s *Sponsor) SubmitSponsoredTransaction(ctx context.Context, txBytes []byte, userSignature string) (*ExecuteTransactionResponse, error) {
	txBytesB64 := base64.StdEncoding.EncodeToString(txBytes)
	txHash := fmt.Sprintf("0x%x", txBytes[:32])

	result, err := s.avsClient.ApproveSponsorTx(txHash)
	if err != nil {
		return nil, fmt.Errorf("avs approve sponsor tx: %w", err)
	}
	if result.Status != "authorized" {
		return nil, fmt.Errorf("avs rejected sponsorship: %s", result.Reason)
	}

	var signatures [][]byte
	var bitmap uint16
	for i, sig := range result.Authorization.Signatures {
		signatures = append(signatures, sig.Signature)
		bitmap |= 1 << uint(i)
	}

	sponsorMultisig := CombineMultisigSignature(
		s.operatorPubKeys,
		signatures,
		s.threshold,
		bitmap,
	)

	resp, err := s.suiClient.ExecuteTransactionBlock(ctx, txBytesB64, []string{userSignature, sponsorMultisig})
	if err != nil {
		return nil, fmt.Errorf("execute sponsored transaction: %w", err)
	}

	return resp, nil
}

func (s *Sponsor) RelayUserTransaction(ctx context.Context, txBytes []byte, userSignature string) (*ExecuteTransactionResponse, error) {
	txBytesB64 := base64.StdEncoding.EncodeToString(txBytes)
	resp, err := s.suiClient.ExecuteTransactionBlock(ctx, txBytesB64, []string{userSignature})
	if err != nil {
		return nil, fmt.Errorf("relay transaction: %w", err)
	}
	return resp, nil
}
