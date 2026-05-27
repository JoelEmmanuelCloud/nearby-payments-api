package walrus

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

const (
	defaultPublisherURL  = "https://publisher.walrus-testnet.walrus.space"
	defaultAggregatorURL = "https://aggregator.walrus-testnet.walrus.space"
	uploadEpochs         = 90
)

type Client struct {
	publisherURL  string
	aggregatorURL string
	httpClient    *http.Client
}

func NewClient(publisherURL, aggregatorURL string) *Client {
	if publisherURL == "" {
		publisherURL = defaultPublisherURL
	}
	if aggregatorURL == "" {
		aggregatorURL = defaultAggregatorURL
	}
	return &Client{
		publisherURL:  publisherURL,
		aggregatorURL: aggregatorURL,
		httpClient:    &http.Client{Timeout: 30 * time.Second},
	}
}

type uploadResponse struct {
	NewlyCreated *struct {
		BlobObject struct {
			BlobID string `json:"blobId"`
		} `json:"blobObject"`
	} `json:"newlyCreated"`
	AlreadyExists *struct {
		BlobID string `json:"blobId"`
	} `json:"alreadyExists"`
}

func (c *Client) UploadBlob(ctx context.Context, contentType string, data []byte) (string, error) {
	endpoint := fmt.Sprintf("%s/v1/blobs?epochs=%d", c.publisherURL, uploadEpochs)

	req, err := http.NewRequestWithContext(ctx, http.MethodPut, endpoint, bytes.NewReader(data))
	if err != nil {
		return "", err
	}
	req.Header.Set("Content-Type", contentType)

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return "", fmt.Errorf("walrus request failed: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("walrus response read failed: %w", err)
	}

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		return "", fmt.Errorf("walrus upload failed: status=%d body=%s", resp.StatusCode, string(body))
	}

	var result uploadResponse
	if err := json.Unmarshal(body, &result); err != nil {
		return "", fmt.Errorf("walrus response parse failed: %w", err)
	}

	if result.NewlyCreated != nil {
		return result.NewlyCreated.BlobObject.BlobID, nil
	}
	if result.AlreadyExists != nil {
		return result.AlreadyExists.BlobID, nil
	}
	return "", fmt.Errorf("walrus unexpected response shape")
}

func (c *Client) AggregatorURL(blobID string) string {
	return fmt.Sprintf("%s/v1/blobs/%s", c.aggregatorURL, blobID)
}
