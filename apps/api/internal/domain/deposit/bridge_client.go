package deposit

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

type BridgeClient struct {
	apiKey  string
	baseURL string
	http    *http.Client
}

func NewBridgeClient(apiKey, baseURL string) *BridgeClient {
	return &BridgeClient{
		apiKey:  apiKey,
		baseURL: baseURL,
		http:    &http.Client{},
	}
}

func (c *BridgeClient) do(ctx context.Context, method, path string, body interface{}, result interface{}) error {
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
	req.Header.Set("Api-Key", c.apiKey)
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.http.Do(req)
	if err != nil {
		return fmt.Errorf("bridge api call %s %s: %w", method, path, err)
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Errorf("read response body: %w", err)
	}

	if resp.StatusCode >= 400 {
		return fmt.Errorf("bridge api error %d: %s", resp.StatusCode, string(respBody))
	}

	if result != nil {
		return json.Unmarshal(respBody, result)
	}
	return nil
}

func (c *BridgeClient) CreateHostedKycLink(ctx context.Context, userID, customerType, endorsement string) (*BridgeHostedKycLink, error) {
	body := map[string]interface{}{
		"full_name":   "Nearby Payments User",
		"email":       userID + "@nearby.app",
		"type":        customerType,
		"endorsement": endorsement,
	}

	var result struct {
		ID         string `json:"id"`
		CustomerID string `json:"customer_id"`
		KycLink    string `json:"kyc_link"`
		TosLink    string `json:"tos_link"`
		KycStatus  string `json:"kyc_status"`
	}

	if err := c.do(ctx, http.MethodPost, "/v0/kyc_links", body, &result); err != nil {
		return nil, fmt.Errorf("create kyc link: %w", err)
	}

	return &BridgeHostedKycLink{
		ID:         result.ID,
		CustomerID: result.CustomerID,
		KycURL:     result.KycLink,
		TosURL:     result.TosLink,
		Status:     result.KycStatus,
	}, nil
}

func (c *BridgeClient) GetCustomerEligibility(ctx context.Context, customerID string) (*BridgeCustomerEligibility, error) {
	var result struct {
		KycStatus   string `json:"kyc_status"`
		Endorsements []struct {
			Name   string `json:"endorsement"`
			Status string `json:"status"`
		} `json:"endorsements"`
	}

	if err := c.do(ctx, http.MethodGet, "/v0/customers/"+customerID, nil, &result); err != nil {
		return nil, fmt.Errorf("get customer: %w", err)
	}

	endorsed := false
	for _, e := range result.Endorsements {
		if e.Name == "base" && e.Status == "approved" {
			endorsed = true
		}
	}

	return &BridgeCustomerEligibility{
		KycStatus:   result.KycStatus,
		Endorsed:    endorsed,
		Endorsement: "base",
	}, nil
}

func (c *BridgeClient) GetKycLink(ctx context.Context, kycLinkID string) (*BridgeHostedKycLink, error) {
	var result struct {
		ID         string `json:"id"`
		CustomerID string `json:"customer_id"`
		KycLink    string `json:"kyc_link"`
		TosLink    string `json:"tos_link"`
		KycStatus  string `json:"kyc_status"`
	}

	if err := c.do(ctx, http.MethodGet, "/v0/kyc_links/"+kycLinkID, nil, &result); err != nil {
		return nil, fmt.Errorf("get kyc link: %w", err)
	}

	return &BridgeHostedKycLink{
		ID:         result.ID,
		CustomerID: result.CustomerID,
		KycURL:     result.KycLink,
		TosURL:     result.TosLink,
		Status:     result.KycStatus,
	}, nil
}

func (c *BridgeClient) EnsureVirtualAccount(ctx context.Context, customerID, destinationAddress string) (*BridgeVirtualAccount, error) {
	var listResult struct {
		Data []struct {
			ID       string `json:"id"`
			Currency string `json:"currency"`
			BankAccount struct {
				BankName   string `json:"bank_name"`
				LastFour   string `json:"last_four"`
				Routing    string `json:"routing_number"`
				AccountHolder string `json:"account_holder_name"`
			} `json:"bank_account"`
			Source struct {
				Payment []string `json:"payment_rail"`
			} `json:"source"`
		} `json:"data"`
	}

	listPath := "/v0/customers/" + customerID + "/virtual_accounts"
	if err := c.do(ctx, http.MethodGet, listPath, nil, &listResult); err == nil {
		for _, va := range listResult.Data {
			if va.Currency == "usd" {
				return &BridgeVirtualAccount{
					ID:                 va.ID,
					Currency:           "usd",
					Rails:              va.Source.Payment,
					BankName:           va.BankAccount.BankName,
					AccountNumberLast4: va.BankAccount.LastFour,
					RoutingNumber:      va.BankAccount.Routing,
					AccountHolderName:  va.BankAccount.AccountHolder,
				}, nil
			}
		}
	}

	body := map[string]interface{}{
		"source": map[string]interface{}{
			"currency":      "usd",
			"payment_rail":  []string{"ach_push", "wire"},
		},
		"destination": map[string]interface{}{
			"currency":      "usdc",
			"payment_rail":  "sui",
			"to_address":    destinationAddress,
		},
	}

	var createResult struct {
		ID       string `json:"id"`
		Currency string `json:"currency"`
		BankAccount struct {
			BankName   string `json:"bank_name"`
			LastFour   string `json:"last_four"`
			Routing    string `json:"routing_number"`
			AccountHolder string `json:"account_holder_name"`
		} `json:"bank_account"`
	}

	createPath := "/v0/customers/" + customerID + "/virtual_accounts"
	if err := c.do(ctx, http.MethodPost, createPath, body, &createResult); err != nil {
		return nil, fmt.Errorf("create virtual account: %w", err)
	}

	return &BridgeVirtualAccount{
		ID:                 createResult.ID,
		Currency:           "usd",
		Rails:              []string{"ach_push", "wire"},
		BankName:           createResult.BankAccount.BankName,
		AccountNumberLast4: createResult.BankAccount.LastFour,
		RoutingNumber:      createResult.BankAccount.Routing,
		AccountHolderName:  createResult.BankAccount.AccountHolder,
	}, nil
}

func (c *BridgeClient) EnsureLiquidationAddress(ctx context.Context, customerID, chain, currency, destinationAddress string) (*BridgeLiquidationAddress, error) {
	listPath := "/v0/customers/" + customerID + "/liquidation_addresses"
	var listResult struct {
		Data []struct {
			ID       string `json:"id"`
			Chain    string `json:"chain"`
			Currency string `json:"currency"`
			Address  string `json:"address"`
		} `json:"data"`
	}

	if err := c.do(ctx, http.MethodGet, listPath, nil, &listResult); err == nil {
		for _, la := range listResult.Data {
			if la.Chain == chain && la.Currency == currency {
				return &BridgeLiquidationAddress{
					ID:       la.ID,
					Address:  la.Address,
					Chain:    la.Chain,
					Currency: la.Currency,
				}, nil
			}
		}
	}

	body := map[string]interface{}{
		"chain":    chain,
		"currency": currency,
		"destination": map[string]interface{}{
			"currency":     "usdc",
			"payment_rail": "sui",
			"to_address":   destinationAddress,
		},
	}

	var createResult struct {
		ID      string `json:"id"`
		Chain   string `json:"chain"`
		Currency string `json:"currency"`
		Address string `json:"address"`
	}

	if err := c.do(ctx, http.MethodPost, listPath, body, &createResult); err != nil {
		return nil, fmt.Errorf("create liquidation address chain=%s currency=%s: %w", chain, currency, err)
	}

	return &BridgeLiquidationAddress{
		ID:       createResult.ID,
		Address:  createResult.Address,
		Chain:    createResult.Chain,
		Currency: createResult.Currency,
	}, nil
}
