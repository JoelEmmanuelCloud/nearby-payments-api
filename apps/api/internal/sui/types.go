package sui

import "fmt"

type ExecuteTransactionResponse struct {
	Digest  string                 `json:"digest"`
	Effects map[string]interface{} `json:"effects"`
	Errors  []string               `json:"errors,omitempty"`
}

func (r *ExecuteTransactionResponse) ExecutionError() error {
	status, ok := r.Effects["status"].(map[string]interface{})
	if !ok {
		return fmt.Errorf("transaction %s returned no execution effects", r.Digest)
	}

	switch s, _ := status["status"].(string); s {
	case "success":
		return nil
	case "failure":
		if msg, _ := status["error"].(string); msg != "" {
			return fmt.Errorf("transaction %s failed on-chain: %s", r.Digest, msg)
		}
		return fmt.Errorf("transaction %s failed on-chain", r.Digest)
	default:
		return fmt.Errorf("transaction %s returned unknown execution status %q", r.Digest, s)
	}
}

type TransactionStatus struct {
	Digest    string
	Status    string
	Timestamp int64
}

type CoinObject struct {
	CoinType     string `json:"coinType"`
	CoinObjectID string `json:"coinObjectId"`
	Version      string `json:"version"`
	Digest       string `json:"digest"`
	Balance      string `json:"balance"`
}

type SponsoredTxRequest struct {
	KindBytes []byte
	Sender    string
	SuiRPCURL string
}

type SponsoredTxResult struct {
	TxBytes          []byte
	SponsorAddress   string
	SponsorSignature string
}
