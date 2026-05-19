package deposit

type NgnAccount struct {
	AccountNumber string `json:"accountNumber"`
	AccountName   string `json:"accountName"`
	BankName      string `json:"bankName"`
	Currency      string `json:"currency"`
}

type NgnAccountState struct {
	Kind    string     `json:"kind"`
	Account NgnAccount `json:"account"`
}

type CryptoDepositState struct {
	Kind   string               `json:"kind"`
	Routes []CryptoDepositRoute `json:"routes"`
}

type CryptoDepositRoute struct {
	Network  string `json:"network"`
	Currency string `json:"currency"`
	Address  string `json:"address"`
}

type DepositOptionsResponse struct {
	FiatNgn interface{}        `json:"fiatNgn"`
	Crypto  CryptoDepositState `json:"crypto"`
}

type FincraLink struct {
	UserID                 string
	FincraCustomerID       string
	FincraVirtualAccountID string
	AccountNumber          string
	AccountName            string
	BankName               string
	CreatedAt              int64
	UpdatedAt              int64
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

type WebhookEvent struct {
	ID              string
	Provider        string
	ProviderEventID string
	EventType       string
	RawPayload      []byte
	Processed       bool
	CreatedAt       int64
}
