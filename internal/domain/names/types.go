package names

type NameOperationTask struct {
	ID          string
	UserID      string
	SuiAddress  string
	LeafName    string
	ParentName  string
	Action      string
	Status      string
	TxDigest    string
	AuthTaskID  string
	ErrorMsg    string
	CreatedAt   int64
	UpdatedAt   int64
}

type RegisterLeafRequest struct {
	LeafName   string `json:"leafName"`
	ParentName string `json:"parentName"`
}

type RegisterLeafResponse struct {
	TaskID     string `json:"taskId"`
	LeafName   string `json:"leafName"`
	ParentName string `json:"parentName"`
	Status     string `json:"status"`
	TxDigest   string `json:"txDigest,omitempty"`
}

type GetTaskResponse struct {
	TaskID     string `json:"taskId"`
	LeafName   string `json:"leafName"`
	ParentName string `json:"parentName"`
	Action     string `json:"action"`
	Status     string `json:"status"`
	TxDigest   string `json:"txDigest,omitempty"`
	ErrorMsg   string `json:"errorMsg,omitempty"`
	CreatedAt  int64  `json:"createdAt"`
	UpdatedAt  int64  `json:"updatedAt"`
}
