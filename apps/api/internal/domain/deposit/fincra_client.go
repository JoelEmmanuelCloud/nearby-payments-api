package deposit

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

type FincraClient struct {
	apiKey  string
	baseURL string
	http    *http.Client
}

func NewFincraClient(apiKey, baseURL string) *FincraClient {
	return &FincraClient{
		apiKey:  apiKey,
		baseURL: baseURL,
		http:    &http.Client{},
	}
}

func (c *FincraClient) do(ctx context.Context, method, path string, body interface{}, result interface{}) error {
	var bodyReader io.Reader
	if body != nil {
		data, err := json.Marshal(body)
		if err != nil {
			return fmt.Errorf("marshal request body: %w", err)
		}
		bodyReader = bytes.NewReader(data)
	}

	req, err := http.NewRequestWithContext(ctx, method, c.baseURL+path, bodyReader)
	if err != nil {
		return fmt.Errorf("create request: %w", err)
	}
	req.Header.Set("api-key", c.apiKey)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")

	resp, err := c.http.Do(req)
	if err != nil {
		return fmt.Errorf("fincra api call %s %s: %w", method, path, err)
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Errorf("read response body: %w", err)
	}

	if resp.StatusCode >= 400 {
		return fmt.Errorf("fincra api error %d: %s", resp.StatusCode, string(respBody))
	}

	if result != nil {
		return json.Unmarshal(respBody, result)
	}
	return nil
}

type FincraVirtualAccount struct {
	ID            string
	AccountNumber string
	AccountName   string
	BankName      string
}

func (c *FincraClient) CreateVirtualAccount(ctx context.Context, userID, firstName, lastName string) (*FincraVirtualAccount, error) {
	body := map[string]interface{}{
		"currency":    "NGN",
		"accountType": "individual",
		"KYCInformation": map[string]interface{}{
			"firstName": firstName,
			"lastName":  lastName,
		},
		"metadata": map[string]string{
			"userId": userID,
		},
	}

	var result struct {
		Success bool `json:"success"`
		Data    struct {
			ID            string `json:"_id"`
			AccountNumber string `json:"accountNumber"`
			AccountName   string `json:"accountName"`
			BankName      string `json:"bankName"`
		} `json:"data"`
	}

	if err := c.do(ctx, http.MethodPost, "/profile/virtual-accounts/requests", body, &result); err != nil {
		return nil, fmt.Errorf("create virtual account: %w", err)
	}

	return &FincraVirtualAccount{
		ID:            result.Data.ID,
		AccountNumber: result.Data.AccountNumber,
		AccountName:   result.Data.AccountName,
		BankName:      result.Data.BankName,
	}, nil
}
