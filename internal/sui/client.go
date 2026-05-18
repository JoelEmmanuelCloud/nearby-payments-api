package sui

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

type Client struct {
	rpcURL     string
	httpClient *http.Client
}

func NewClient(rpcURL string) *Client {
	return &Client{
		rpcURL:     rpcURL,
		httpClient: &http.Client{},
	}
}

type rpcRequest struct {
	JSONRPC string        `json:"jsonrpc"`
	ID      int           `json:"id"`
	Method  string        `json:"method"`
	Params  []interface{} `json:"params"`
}

type rpcResponse struct {
	JSONRPC string          `json:"jsonrpc"`
	ID      int             `json:"id"`
	Result  json.RawMessage `json:"result,omitempty"`
	Error   *rpcError       `json:"error,omitempty"`
}

type rpcError struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

func (c *Client) call(ctx context.Context, method string, params []interface{}, result interface{}) error {
	req := rpcRequest{
		JSONRPC: "2.0",
		ID:      1,
		Method:  method,
		Params:  params,
	}

	body, err := json.Marshal(req)
	if err != nil {
		return fmt.Errorf("marshal rpc request: %w", err)
	}

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, c.rpcURL, bytes.NewReader(body))
	if err != nil {
		return fmt.Errorf("create http request: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")

	resp, err := c.httpClient.Do(httpReq)
	if err != nil {
		return fmt.Errorf("rpc call %s: %w", method, err)
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Errorf("read response body: %w", err)
	}

	var rpcResp rpcResponse
	if err := json.Unmarshal(respBody, &rpcResp); err != nil {
		return fmt.Errorf("unmarshal rpc response: %w", err)
	}

	if rpcResp.Error != nil {
		return fmt.Errorf("rpc error %d: %s", rpcResp.Error.Code, rpcResp.Error.Message)
	}

	if result != nil && rpcResp.Result != nil {
		return json.Unmarshal(rpcResp.Result, result)
	}

	return nil
}

func (c *Client) ExecuteTransactionBlock(ctx context.Context, txBytes string, signatures []string) (*ExecuteTransactionResponse, error) {
	params := []interface{}{
		txBytes,
		signatures,
		map[string]interface{}{
			"showEffects":       true,
			"showObjectChanges": true,
		},
		"WaitForLocalExecution",
	}

	var result ExecuteTransactionResponse
	if err := c.call(ctx, "sui_executeTransactionBlock", params, &result); err != nil {
		return nil, fmt.Errorf("execute transaction block: %w", err)
	}

	return &result, nil
}

func (c *Client) GetCoins(ctx context.Context, address, coinType string) ([]CoinObject, error) {
	params := []interface{}{address, coinType, nil, 10}

	var result struct {
		Data []CoinObject `json:"data"`
	}
	if err := c.call(ctx, "suix_getCoins", params, &result); err != nil {
		return nil, fmt.Errorf("get coins: %w", err)
	}

	return result.Data, nil
}

func (c *Client) GetTransactionBlock(ctx context.Context, digest string) (*ExecuteTransactionResponse, error) {
	params := []interface{}{
		digest,
		map[string]interface{}{
			"showEffects":       true,
			"showObjectChanges": true,
		},
	}

	var result ExecuteTransactionResponse
	if err := c.call(ctx, "sui_getTransactionBlock", params, &result); err != nil {
		return nil, fmt.Errorf("get transaction block: %w", err)
	}

	return &result, nil
}
