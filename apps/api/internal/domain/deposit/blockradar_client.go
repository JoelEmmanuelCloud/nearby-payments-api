package deposit

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

type BlockradarClient struct {
	apiKey   string
	walletID string
	baseURL  string
	http     *http.Client
}

func NewBlockradarClient(apiKey, walletID, baseURL string) *BlockradarClient {
	return &BlockradarClient{
		apiKey:   apiKey,
		walletID: walletID,
		baseURL:  baseURL,
		http:     &http.Client{},
	}
}

func (c *BlockradarClient) do(ctx context.Context, method, path string, body interface{}, result interface{}) error {
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
	req.Header.Set("x-api-key", c.apiKey)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")

	resp, err := c.http.Do(req)
	if err != nil {
		return fmt.Errorf("blockradar api call %s %s: %w", method, path, err)
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Errorf("read response body: %w", err)
	}

	if resp.StatusCode >= 400 {
		return fmt.Errorf("blockradar api error %d: %s", resp.StatusCode, string(respBody))
	}

	if result != nil {
		return json.Unmarshal(respBody, result)
	}
	return nil
}

type BlockradarAddress struct {
	ID      string
	Address string
	Network string
	Label   string
}

func (c *BlockradarClient) EnsureDepositAddress(ctx context.Context, network, label string) (*BlockradarAddress, error) {
	var listResult struct {
		Data []struct {
			ID      string `json:"id"`
			Address string `json:"address"`
			Network string `json:"network"`
			Label   string `json:"label"`
		} `json:"data"`
	}

	listPath := fmt.Sprintf("/wallets/%s/addresses?label=%s&network=%s", c.walletID, label, network)
	if err := c.do(ctx, http.MethodGet, listPath, nil, &listResult); err == nil {
		for _, a := range listResult.Data {
			if a.Label == label && a.Network == network {
				return &BlockradarAddress{
					ID:      a.ID,
					Address: a.Address,
					Network: a.Network,
					Label:   a.Label,
				}, nil
			}
		}
	}

	body := map[string]string{
		"network": network,
		"label":   label,
	}

	var createResult struct {
		Data struct {
			ID      string `json:"id"`
			Address string `json:"address"`
			Network string `json:"network"`
			Label   string `json:"label"`
		} `json:"data"`
	}

	createPath := fmt.Sprintf("/wallets/%s/addresses", c.walletID)
	if err := c.do(ctx, http.MethodPost, createPath, body, &createResult); err != nil {
		return nil, fmt.Errorf("create deposit address network=%s: %w", network, err)
	}

	return &BlockradarAddress{
		ID:      createResult.Data.ID,
		Address: createResult.Data.Address,
		Network: createResult.Data.Network,
		Label:   createResult.Data.Label,
	}, nil
}
