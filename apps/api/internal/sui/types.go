package sui

type ExecuteTransactionResponse struct {
	Digest  string                 `json:"digest"`
	Effects map[string]interface{} `json:"effects"`
	Errors  []string               `json:"errors,omitempty"`
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
	KindBytes   []byte
	Sender      string
	SuiRPCURL   string
}

type SponsoredTxResult struct {
	TxBytes         []byte
	SponsorAddress  string
	SponsorSignature string
}
