package avs

const (
	ActionLeafRegisterInitial = "leaf_name.register_initial"
	ActionParentRenew         = "parent_name.renew"
	ActionParentAdminRecover  = "parent_name.admin_recover"
	ActionSponsorTxApprove    = "sponsor_tx.approve"
)

var AllowedActions = map[string]bool{
	ActionLeafRegisterInitial: true,
	ActionParentRenew:         true,
	ActionParentAdminRecover:  true,
	ActionSponsorTxApprove:    true,
}

type AuthorizationPayload struct {
	Version       int    `json:"version"`
	Domain        string `json:"domain"`
	Chain         string `json:"chain"`
	Action        string `json:"action"`
	TargetPackage string `json:"targetPackage"`
	TargetObject  string `json:"targetObject"`
	PayloadHash   string `json:"payloadHash"`
	Nonce         string `json:"nonce"`
	IssuedAtMs    int64  `json:"issuedAtMs"`
	ExpiresAtMs   int64  `json:"expiresAtMs"`
}

type LeafRegistrationInput struct {
	Label             string
	ParentName        string
	LeafName          string
	UserAddress       string
	WalletBindingHash string
	TargetPackage     string
	TargetObject      string
}

type SponsorTxInput struct {
	TransactionBytesHash string
	TargetPackage        string
	TargetObject         string
}

type OperatorSignature struct {
	OperatorID string
	PublicKey  []byte
	Signature  []byte
}

type Authorization struct {
	Version         int
	Action          string
	PayloadHash     string
	Nonce           string
	ExpiresAtMs     int64
	SignerSetID     string
	Signers         []string
	Signatures      []OperatorSignature
	MultisigAddress string
}

type AuthorizeResult struct {
	Status        string
	Authorization *Authorization
	TaskID        string
	RetryAfterMs  int64
	Reason        string
}

type SignerSetInfo struct {
	ID              string
	PublicKeys      [][]byte
	MultisigAddress string
	Threshold       int
}
