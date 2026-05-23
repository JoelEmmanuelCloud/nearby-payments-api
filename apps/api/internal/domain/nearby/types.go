package nearby

type NearbySession struct {
	ID              string
	InitiatorUserID string
	RecipientUserID string
	Status          string
	PayloadType     string
	PayloadData     string
	CreatedAt       int64
	UpdatedAt       int64
	ExpiresAt       int64
}

type InitiateSessionRequest struct {
	RecipientSuiAddress string `json:"recipientSuiAddress"`
	PayloadType         string `json:"payloadType"`
	PayloadData         string `json:"payloadData"`
}

type InitiateSessionResponse struct {
	SessionID           string `json:"sessionId"`
	RecipientSuiAddress string `json:"recipientSuiAddress"`
	PayloadType         string `json:"payloadType"`
	Status              string `json:"status"`
	ExpiresAt           int64  `json:"expiresAt"`
}

type GetSessionResponse struct {
	SessionID           string `json:"sessionId"`
	InitiatorSuiAddress string `json:"initiatorSuiAddress,omitempty"`
	RecipientSuiAddress string `json:"recipientSuiAddress,omitempty"`
	PayloadType         string `json:"payloadType"`
	PayloadData         string `json:"payloadData"`
	Status              string `json:"status"`
	CreatedAt           int64  `json:"createdAt"`
	ExpiresAt           int64  `json:"expiresAt"`
}

type AcknowledgeSessionRequest struct {
	Accept bool `json:"accept"`
}

type AcknowledgeSessionResponse struct {
	SessionID string `json:"sessionId"`
	Status    string `json:"status"`
}
