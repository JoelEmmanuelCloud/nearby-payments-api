package deposit

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"strings"
	"time"

	"github.com/vaariance/nearby/internal/utils"
)

type Processor struct {
	store *Store
}

func NewProcessor(store *Store) *Processor {
	return &Processor{store: store}
}

func (p *Processor) Run(ctx context.Context) {
	ticker := time.NewTicker(10 * time.Second)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			p.processAll(ctx)
		}
	}
}

func (p *Processor) ProcessNow(ctx context.Context) {
	p.processAll(ctx)
}

func (p *Processor) processAll(ctx context.Context) {
	events, err := p.store.GetUnprocessedWebhookEvents(ctx, 50)
	if err != nil {
		slog.Error("fetch unprocessed webhook events", "error", err)
		return
	}
	for _, ev := range events {
		if err := p.process(ctx, ev); err != nil {
			slog.Error("process webhook event", "event_id", ev.ID, "event_type", ev.EventType, "error", err)
			continue
		}
		if err := p.store.MarkWebhookEventProcessed(ctx, ev.ID); err != nil {
			slog.Error("mark webhook event processed", "event_id", ev.ID, "error", err)
		}
	}
}

func (p *Processor) process(ctx context.Context, ev *BridgeWebhookEvent) error {
	switch {
	case ev.EventType == "virtual_account.activity":
		return p.processVirtualAccountActivity(ctx, ev)
	case ev.EventType == "liquidation_address.drain":
		return p.processLiquidationDrain(ctx, ev)
	case strings.HasPrefix(ev.EventType, "kyc_link."):
		return nil
	default:
		slog.Warn("unhandled webhook event type", "event_type", ev.EventType)
		return nil
	}
}

func (p *Processor) processVirtualAccountActivity(ctx context.Context, ev *BridgeWebhookEvent) error {
	var envelope struct {
		Data struct {
			ID               string `json:"id"`
			VirtualAccountID string `json:"virtual_account_id"`
			Status           string `json:"status"`
			Receipt          struct {
				InitialAmount string `json:"initial_amount"`
				Currency      string `json:"currency"`
			} `json:"receipt"`
			Destination struct {
				TxHash string `json:"tx_hash"`
			} `json:"destination"`
		} `json:"data"`
	}
	if err := json.Unmarshal(ev.RawPayload, &envelope); err != nil {
		return fmt.Errorf("parse virtual_account.activity payload: %w", err)
	}

	d := envelope.Data
	if d.VirtualAccountID == "" || d.Status == "" {
		return nil
	}

	route, err := p.store.GetDepositRouteByProviderRouteID(ctx, d.VirtualAccountID)
	if err != nil {
		return fmt.Errorf("get deposit route for virtual_account %s: %w", d.VirtualAccountID, err)
	}
	if route == nil {
		slog.Warn("no deposit route found for virtual_account", "virtual_account_id", d.VirtualAccountID)
		return nil
	}

	now := utils.NowUnix()
	return p.store.UpsertDeposit(ctx, &Deposit{
		ID:                utils.NewID(),
		UserID:            route.UserID,
		RouteID:           route.ID,
		Provider:          "bridge",
		ProviderDepositID: d.ID,
		Kind:              "virtual_account",
		Status:            d.Status,
		Amount:            d.Receipt.InitialAmount,
		Currency:          d.Receipt.Currency,
		TxHash:            d.Destination.TxHash,
		CreatedAt:         now,
		UpdatedAt:         now,
	})
}

func (p *Processor) processLiquidationDrain(ctx context.Context, ev *BridgeWebhookEvent) error {
	var envelope struct {
		Data struct {
			ID                   string `json:"id"`
			LiquidationAddressID string `json:"liquidation_address_id"`
			Amount               string `json:"amount"`
			Currency             string `json:"currency"`
			Status               string `json:"status"`
			Destination          struct {
				TxHash string `json:"tx_hash"`
			} `json:"destination"`
		} `json:"data"`
	}
	if err := json.Unmarshal(ev.RawPayload, &envelope); err != nil {
		return fmt.Errorf("parse liquidation_address.drain payload: %w", err)
	}

	d := envelope.Data
	if d.LiquidationAddressID == "" || d.Status == "" {
		return nil
	}

	route, err := p.store.GetDepositRouteByProviderRouteID(ctx, d.LiquidationAddressID)
	if err != nil {
		return fmt.Errorf("get deposit route for liquidation_address %s: %w", d.LiquidationAddressID, err)
	}
	if route == nil {
		slog.Warn("no deposit route found for liquidation_address", "liquidation_address_id", d.LiquidationAddressID)
		return nil
	}

	now := utils.NowUnix()
	return p.store.UpsertDeposit(ctx, &Deposit{
		ID:                utils.NewID(),
		UserID:            route.UserID,
		RouteID:           route.ID,
		Provider:          "bridge",
		ProviderDepositID: d.ID,
		Kind:              "liquidation_address",
		Status:            d.Status,
		Amount:            d.Amount,
		Currency:          d.Currency,
		TxHash:            d.Destination.TxHash,
		CreatedAt:         now,
		UpdatedAt:         now,
	})
}
