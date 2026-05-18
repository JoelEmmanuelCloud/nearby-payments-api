package payment

type PaymentIntent struct {
	ID             string
	UserID         string
	IdempotencyKey string
	RecipientAddress string
	RecipientName  string
	Asset          string
	AmountAtomic   string
	Status         string
	TxDigest       string
	SponsorAddress string
	FundingMode    string
	CreatedAt      int64
	UpdatedAt      int64
	ExpiresAt      int64
}

type Payment struct {
	ID               string
	IntentID         string
	UserID           string
	RecipientAddress string
	Asset            string
	AmountAtomic     string
	TxDigest         string
	Status           string
	ConfirmedAt      int64
	CreatedAt        int64
}

type CreateIntentRequest struct {
	RecipientAddress string `json:"recipientAddress"`
	RecipientName    string `json:"recipientName"`
	Asset            string `json:"asset"`
	AmountAtomic     string `json:"amountAtomic"`
	FundingMode      string `json:"fundingMode"`
	IdempotencyKey   string `json:"idempotencyKey"`
}

type CreateIntentResponse struct {
	IntentID       string `json:"intentId"`
	RecipientAddress string `json:"recipientAddress"`
	Asset          string `json:"asset"`
	AmountAtomic   string `json:"amountAtomic"`
	FundingMode    string `json:"fundingMode"`
	SponsorAddress string `json:"sponsorAddress,omitempty"`
	Status         string `json:"status"`
	ExpiresAt      int64  `json:"expiresAt"`
}

type SubmitIntentRequest struct {
	TxBytes        string `json:"txBytes"`
	UserSignature  string `json:"userSignature"`
}

type SubmitIntentResponse struct {
	PaymentID string `json:"paymentId"`
	TxDigest  string `json:"txDigest"`
	Status    string `json:"status"`
}

type GetIntentResponse struct {
	IntentID       string `json:"intentId"`
	Status         string `json:"status"`
	RecipientAddress string `json:"recipientAddress"`
	Asset          string `json:"asset"`
	AmountAtomic   string `json:"amountAtomic"`
	TxDigest       string `json:"txDigest,omitempty"`
	CreatedAt      int64  `json:"createdAt"`
	ExpiresAt      int64  `json:"expiresAt"`
}

type GetPaymentResponse struct {
	PaymentID        string `json:"paymentId"`
	IntentID         string `json:"intentId"`
	RecipientAddress string `json:"recipientAddress"`
	Asset            string `json:"asset"`
	AmountAtomic     string `json:"amountAtomic"`
	TxDigest         string `json:"txDigest"`
	Status           string `json:"status"`
	ConfirmedAt      int64  `json:"confirmedAt,omitempty"`
	CreatedAt        int64  `json:"createdAt"`
}
