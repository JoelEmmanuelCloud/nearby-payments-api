package names

type NameOperationTask struct {
	ID          string
	UserID      string
	Action      string
	PayloadHash string
	Nonce       string
	Status      string
	AVSTaskID   string
	CreatedAt   int64
	UpdatedAt   int64
	ExpiresAt   int64
}

type RegisterLeafRequest struct {
	LeafName string `json:"leafName"`
}

type RegisterLeafResponse struct {
	TaskID         string `json:"taskId"`
	NameHash       string `json:"nameHash"`
	Action         string `json:"action"`
	Status         string `json:"status"`
	SponsorAddress string `json:"sponsorAddress,omitempty"`
	ExpiresAt      int64  `json:"expiresAt"`
}

type SubmitLeafRequest struct {
	TxBytes       string `json:"txBytes"`
	UserSignature string `json:"userSignature"`
}

type SubmitLeafResponse struct {
	TaskID   string `json:"taskId"`
	TxDigest string `json:"txDigest"`
	Status   string `json:"status"`
}

type GetTaskResponse struct {
	TaskID    string `json:"taskId"`
	NameHash  string `json:"nameHash"`
	Action    string `json:"action"`
	Status    string `json:"status"`
	CreatedAt int64  `json:"createdAt"`
	UpdatedAt int64  `json:"updatedAt"`
	ExpiresAt int64  `json:"expiresAt"`
}

type NameAvailabilityResponse struct {
	Name      string `json:"name"`
	Available bool   `json:"available"`
}
