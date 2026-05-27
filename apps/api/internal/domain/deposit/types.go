package deposit

type FiatUsdDepositState struct {
	Kind string `json:"kind"`
}

type KycRequiredState struct {
	Kind            string `json:"kind"`
	BridgeKycLinkID string `json:"bridgeKycLinkId"`
	KycURL          string `json:"kycUrl"`
	TosURL          string `json:"tosUrl"`
	Status          string `json:"status"`
}

type KycPendingState struct {
	Kind            string `json:"kind"`
	BridgeKycLinkID string `json:"bridgeKycLinkId"`
	Status          string `json:"status"`
}

type AccountDetailsState struct {
	Kind    string     `json:"kind"`
	Account UsdAccount `json:"account"`
}

type UsdAccount struct {
	ID                 string   `json:"id"`
	Currency           string   `json:"currency"`
	Rails              []string `json:"rails"`
	BankName           string   `json:"bankName"`
	AccountNumberLast4 string   `json:"accountNumberLast4"`
	RoutingNumber      string   `json:"routingNumber"`
	AccountHolderName  string   `json:"accountHolderName"`
}

type CryptoDepositState struct {
	Kind   string               `json:"kind"`
	Routes []CryptoDepositRoute `json:"routes"`
}

type CryptoDepositRoute struct {
	Rail            string   `json:"rail"`
	Currency        string   `json:"currency"`
	Address         string   `json:"address"`
	SupportedChains []string `json:"supportedChains,omitempty"`
	MemoRequired    bool     `json:"memoRequired"`
}

type DepositOptionsResponse struct {
	FiatUsd any                `json:"fiatUsd"`
	Crypto  CryptoDepositState `json:"crypto"`
}

type BridgeLink struct {
	UserID           string
	BridgeCustomerID string
	BridgeKycLinkID  string
	CreatedAt        int64
	UpdatedAt        int64
}

type DepositRoute struct {
	ID                  string
	UserID              string
	Provider            string
	ProviderRouteID     string
	Kind                string
	SourceRail          string
	SourceCurrency      string
	SourceAddress       string
	DestinationRail     string
	DestinationCurrency string
	DestinationAddrHash string
	State               string
	CreatedAt           int64
	UpdatedAt           int64
}

type DepositSummary struct {
	ID        string `json:"id"`
	Kind      string `json:"kind"`
	Status    string `json:"status"`
	Amount    string `json:"amount"`
	Currency  string `json:"currency"`
	TxHash    string `json:"txHash"`
	CreatedAt int64  `json:"createdAt"`
	UpdatedAt int64  `json:"updatedAt"`
}

type ListDepositsResponse struct {
	Deposits []DepositSummary `json:"deposits"`
}

type BridgeWebhookEvent struct {
	ID              string
	ProviderEventID string
	EventType       string
	RawPayload      []byte
	Processed       bool
	CreatedAt       int64
}

type BridgeHostedKycLink struct {
	ID         string
	CustomerID string
	KycURL     string
	TosURL     string
	Status     string
}

type BridgeCustomerEligibility struct {
	KycStatus   string
	Endorsed    bool
	Endorsement string
}

type BridgeVirtualAccount struct {
	ID                 string
	Currency           string
	Rails              []string
	BankName           string
	AccountNumberLast4 string
	RoutingNumber      string
	AccountHolderName  string
}

type BridgeLiquidationAddress struct {
	ID       string
	Address  string
	Chain    string
	Currency string
}

type Deposit struct {
	ID                string
	UserID            string
	RouteID           string
	Provider          string
	ProviderDepositID string
	Kind              string
	Status            string
	Amount            string
	Currency          string
	TxHash            string
	CreatedAt         int64
	UpdatedAt         int64
}
