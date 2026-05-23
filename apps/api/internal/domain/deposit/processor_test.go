package deposit_test

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/vaariance/nearby/internal/domain/deposit"
	"github.com/vaariance/nearby/internal/utils"
)

func insertWebhookEvent(t *testing.T, eventType string, payload any) string {
	t.Helper()
	body, err := json.Marshal(payload)
	if err != nil {
		t.Fatalf("marshal webhook payload: %v", err)
	}
	ev := &deposit.BridgeWebhookEvent{
		ID:              utils.NewID(),
		ProviderEventID: utils.NewID(),
		EventType:       eventType,
		RawPayload:      body,
		Processed:       false,
		CreatedAt:       utils.NowUnix(),
	}
	if err := testStore.InsertWebhookEvent(context.Background(), ev); err != nil {
		t.Fatalf("insert webhook event: %v", err)
	}
	t.Cleanup(func() {
		testPool.Exec(context.Background(), `DELETE FROM bridge_webhook_events WHERE id = $1`, ev.ID)
	})
	return ev.ID
}

func TestProcessor_VirtualAccountActivity_CreatesDeposit(t *testing.T) {
	userID := insertTestUser(t)
	vaID := utils.NewID()
	activityID := utils.NewID()

	insertTestDepositRoute(t, userID, vaID, "virtual_account", "fiat", "usd", "")

	insertWebhookEvent(t, "virtual_account.activity", map[string]any{
		"id":   utils.NewID(),
		"type": "virtual_account.activity",
		"data": map[string]any{
			"id":                 activityID,
			"virtual_account_id": vaID,
			"status":             "payment_processed",
			"receipt": map[string]string{
				"initial_amount": "100000",
				"currency":       "usd",
			},
			"destination": map[string]string{
				"tx_hash": "0xfinaltx",
			},
		},
	})

	processor := deposit.NewProcessor(testStore)
	processor.ProcessNow(context.Background())

	deposits, err := testStore.GetDepositsByUserID(context.Background(), userID, 10, 0)
	if err != nil {
		t.Fatalf("get deposits: %v", err)
	}
	if len(deposits) != 1 {
		t.Fatalf("expected 1 deposit after processing, got %d", len(deposits))
	}
	d := deposits[0]
	if d.Status != "payment_processed" {
		t.Fatalf("expected status payment_processed, got %s", d.Status)
	}
	if d.TxHash != "0xfinaltx" {
		t.Fatalf("expected tx_hash 0xfinaltx, got %s", d.TxHash)
	}
	if d.Amount != "100000" {
		t.Fatalf("expected amount 100000, got %s", d.Amount)
	}
	if d.Currency != "usd" {
		t.Fatalf("expected currency usd, got %s", d.Currency)
	}
}

func TestProcessor_LiquidationDrain_CreatesDeposit(t *testing.T) {
	userID := insertTestUser(t)
	laID := utils.NewID()
	drainID := utils.NewID()

	insertTestDepositRoute(t, userID, laID, "liquidation_address", "solana", "usdc", "SolanaAddr123")

	insertWebhookEvent(t, "liquidation_address.drain", map[string]any{
		"id":   utils.NewID(),
		"type": "liquidation_address.drain",
		"data": map[string]any{
			"id":                     drainID,
			"liquidation_address_id": laID,
			"status":                 "payment_processed",
			"amount":                 "500000",
			"currency":               "usdc",
			"destination": map[string]string{
				"tx_hash": "0xdraintx",
			},
		},
	})

	processor := deposit.NewProcessor(testStore)
	processor.ProcessNow(context.Background())

	deposits, err := testStore.GetDepositsByUserID(context.Background(), userID, 10, 0)
	if err != nil {
		t.Fatalf("get deposits: %v", err)
	}
	if len(deposits) != 1 {
		t.Fatalf("expected 1 deposit after processing, got %d", len(deposits))
	}
	d := deposits[0]
	if d.Status != "payment_processed" {
		t.Fatalf("expected status payment_processed, got %s", d.Status)
	}
	if d.Amount != "500000" {
		t.Fatalf("expected amount 500000, got %s", d.Amount)
	}
	if d.TxHash != "0xdraintx" {
		t.Fatalf("expected tx_hash 0xdraintx, got %s", d.TxHash)
	}
	if d.Kind != "liquidation_address" {
		t.Fatalf("expected kind liquidation_address, got %s", d.Kind)
	}
}

func TestProcessor_VirtualAccountActivity_StatusTransition(t *testing.T) {
	userID := insertTestUser(t)
	vaID := utils.NewID()
	activityID := utils.NewID()

	insertTestDepositRoute(t, userID, vaID, "virtual_account", "fiat", "usd", "")

	insertWebhookEvent(t, "virtual_account.activity", map[string]any{
		"id":   utils.NewID(),
		"type": "virtual_account.activity",
		"data": map[string]any{
			"id":                 activityID,
			"virtual_account_id": vaID,
			"status":             "funds_received",
			"receipt": map[string]string{
				"initial_amount": "200000",
				"currency":       "usd",
			},
			"destination": map[string]string{
				"tx_hash": "",
			},
		},
	})

	processor := deposit.NewProcessor(testStore)
	processor.ProcessNow(context.Background())

	deposits, err := testStore.GetDepositsByUserID(context.Background(), userID, 10, 0)
	if err != nil {
		t.Fatalf("get deposits after first event: %v", err)
	}
	if len(deposits) != 1 || deposits[0].Status != "funds_received" {
		t.Fatalf("expected 1 deposit with status funds_received, got %v", deposits)
	}

	insertWebhookEvent(t, "virtual_account.activity", map[string]any{
		"id":   utils.NewID(),
		"type": "virtual_account.activity",
		"data": map[string]any{
			"id":                 activityID,
			"virtual_account_id": vaID,
			"status":             "payment_processed",
			"receipt": map[string]string{
				"initial_amount": "200000",
				"currency":       "usd",
			},
			"destination": map[string]string{
				"tx_hash": "0xsettled",
			},
		},
	})

	processor.ProcessNow(context.Background())

	deposits, err = testStore.GetDepositsByUserID(context.Background(), userID, 10, 0)
	if err != nil {
		t.Fatalf("get deposits after second event: %v", err)
	}
	if len(deposits) != 1 {
		t.Fatalf("expected exactly 1 deposit record (upsert), got %d", len(deposits))
	}
	if deposits[0].Status != "payment_processed" {
		t.Fatalf("expected status payment_processed after transition, got %s", deposits[0].Status)
	}
	if deposits[0].TxHash != "0xsettled" {
		t.Fatalf("expected tx_hash 0xsettled, got %s", deposits[0].TxHash)
	}
}

func TestProcessor_KycLinkEvent_MarkedProcessed(t *testing.T) {
	eventID := insertWebhookEvent(t, "kyc_link.approved", map[string]any{
		"id":   utils.NewID(),
		"type": "kyc_link.approved",
		"data": map[string]string{"status": "approved"},
	})

	processor := deposit.NewProcessor(testStore)
	processor.ProcessNow(context.Background())

	events, err := testStore.GetUnprocessedWebhookEvents(context.Background(), 100)
	if err != nil {
		t.Fatalf("get unprocessed events: %v", err)
	}
	for _, e := range events {
		if e.ID == eventID {
			t.Fatal("kyc_link event should be marked processed after processor run")
		}
	}
}

func TestProcessor_VirtualAccountActivity_RouteNotFound(t *testing.T) {
	eventID := insertWebhookEvent(t, "virtual_account.activity", map[string]any{
		"id":   utils.NewID(),
		"type": "virtual_account.activity",
		"data": map[string]any{
			"id":                 utils.NewID(),
			"virtual_account_id": utils.NewID(),
			"status":             "funds_received",
			"receipt": map[string]string{
				"initial_amount": "100",
				"currency":       "usd",
			},
			"destination": map[string]string{"tx_hash": ""},
		},
	})

	processor := deposit.NewProcessor(testStore)
	processor.ProcessNow(context.Background())

	events, err := testStore.GetUnprocessedWebhookEvents(context.Background(), 100)
	if err != nil {
		t.Fatalf("get unprocessed events: %v", err)
	}
	for _, e := range events {
		if e.ID == eventID {
			t.Fatal("event should be marked processed even when route is not found")
		}
	}
}

func TestProcessor_UnknownEventType_Handled(t *testing.T) {
	eventID := insertWebhookEvent(t, "unknown.event.type", map[string]any{
		"id":   utils.NewID(),
		"type": "unknown.event.type",
		"data": map[string]string{},
	})

	processor := deposit.NewProcessor(testStore)
	processor.ProcessNow(context.Background())

	events, err := testStore.GetUnprocessedWebhookEvents(context.Background(), 100)
	if err != nil {
		t.Fatalf("get unprocessed events: %v", err)
	}
	for _, e := range events {
		if e.ID == eventID {
			t.Fatal("unknown event type should be marked processed without error")
		}
	}
}
