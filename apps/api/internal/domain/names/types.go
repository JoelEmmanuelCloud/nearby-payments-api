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
	LeafName   string `json:"leafName"`
	ParentName string `json:"parentName"`
}

type RegisterLeafResponse struct {
	TaskID    string `json:"taskId"`
	NameHash  string `json:"nameHash"`
	Action    string `json:"action"`
	Status    string `json:"status"`
	ExpiresAt int64  `json:"expiresAt"`
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
