package sui

import "testing"

func TestExecuteTransactionResponseExecutionError(t *testing.T) {
	tests := []struct {
		name    string
		effects map[string]interface{}
		wantErr bool
	}{
		{
			name:    "success",
			effects: map[string]interface{}{"status": map[string]interface{}{"status": "success"}},
			wantErr: false,
		},
		{
			name:    "failure with message",
			effects: map[string]interface{}{"status": map[string]interface{}{"status": "failure", "error": "InsufficientGas"}},
			wantErr: true,
		},
		{
			name:    "failure without message",
			effects: map[string]interface{}{"status": map[string]interface{}{"status": "failure"}},
			wantErr: true,
		},
		{
			name:    "missing effects",
			effects: nil,
			wantErr: true,
		},
		{
			name:    "missing status field",
			effects: map[string]interface{}{"gasUsed": map[string]interface{}{}},
			wantErr: true,
		},
		{
			name:    "unknown status",
			effects: map[string]interface{}{"status": map[string]interface{}{"status": "pending"}},
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			resp := &ExecuteTransactionResponse{Digest: "0xabc", Effects: tt.effects}
			err := resp.ExecutionError()
			if (err != nil) != tt.wantErr {
				t.Fatalf("ExecutionError() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}
