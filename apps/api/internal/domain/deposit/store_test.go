package deposit_test

import (
	"context"
	"testing"

	"github.com/vaariance/nearby/internal/domain/deposit"
	"github.com/vaariance/nearby/internal/utils"
)

func insertTestDepositRoute(t *testing.T, userID, providerRouteID, kind, rail, currency, address string) string {
	t.Helper()
	routeID := utils.NewID()
	_, err := testPool.Exec(context.Background(),
		`INSERT INTO deposit_routes
		 (id, user_id, provider, provider_route_id, kind, source_rail, source_currency,
		  source_address, destination_rail, destination_currency, destination_address_hash, state, created_at, updated_at)
		 VALUES ($1,$2,'bridge',$3,$4,$5,$6,$7,'sui','usdc','hash','active',$8,$8)`,
		routeID, userID, providerRouteID, kind, rail, currency, address, utils.NowUnix(),
	)
	if err != nil {
		t.Fatalf("insert deposit route: %v", err)
	}
	return routeID
}

func TestStoreBridgeLink_NotFound(t *testing.T) {
	link, err := testStore.GetBridgeLinkByUserID(context.Background(), utils.NewID())
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if link != nil {
		t.Fatal("expected nil for missing bridge link")
	}
}

func TestStoreBridgeLink_UpsertAndGet(t *testing.T) {
	userID := insertTestUser(t)
	now := utils.NowUnix()

	bl := &deposit.BridgeLink{
		UserID:           userID,
		BridgeCustomerID: "cust_123",
		BridgeKycLinkID:  "kyc_456",
		CreatedAt:        now,
		UpdatedAt:        now,
	}
	if err := testStore.UpsertBridgeLink(context.Background(), bl); err != nil {
		t.Fatalf("upsert bridge link: %v", err)
	}

	got, err := testStore.GetBridgeLinkByUserID(context.Background(), userID)
	if err != nil {
		t.Fatalf("get bridge link: %v", err)
	}
	if got == nil {
		t.Fatal("expected bridge link, got nil")
	}
	if got.BridgeCustomerID != "cust_123" {
		t.Fatalf("expected customer id cust_123, got %s", got.BridgeCustomerID)
	}
	if got.BridgeKycLinkID != "kyc_456" {
		t.Fatalf("expected kyc link id kyc_456, got %s", got.BridgeKycLinkID)
	}
}

func TestStoreBridgeLink_UpsertUpdates(t *testing.T) {
	userID := insertTestUser(t)
	now := utils.NowUnix()

	if err := testStore.UpsertBridgeLink(context.Background(), &deposit.BridgeLink{
		UserID:           userID,
		BridgeCustomerID: "cust_old",
		BridgeKycLinkID:  "kyc_old",
		CreatedAt:        now,
		UpdatedAt:        now,
	}); err != nil {
		t.Fatalf("first upsert: %v", err)
	}

	if err := testStore.UpsertBridgeLink(context.Background(), &deposit.BridgeLink{
		UserID:           userID,
		BridgeCustomerID: "cust_new",
		BridgeKycLinkID:  "kyc_new",
		CreatedAt:        now,
		UpdatedAt:        now + 1,
	}); err != nil {
		t.Fatalf("second upsert: %v", err)
	}

	got, err := testStore.GetBridgeLinkByUserID(context.Background(), userID)
	if err != nil {
		t.Fatalf("get bridge link: %v", err)
	}
	if got.BridgeCustomerID != "cust_new" {
		t.Fatalf("expected updated customer id cust_new, got %s", got.BridgeCustomerID)
	}
}

func TestStoreDepositRoute_NotFound(t *testing.T) {
	userID := insertTestUser(t)
	route, err := testStore.GetDepositRoute(context.Background(), userID, "liquidation_address", "solana", "usdc")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if route != nil {
		t.Fatal("expected nil for missing deposit route")
	}
}

func TestStoreDepositRoute_CreateAndGetByUser(t *testing.T) {
	userID := insertTestUser(t)
	providerRouteID := utils.NewID()

	dr := &deposit.DepositRoute{
		ID:                  utils.NewID(),
		UserID:              userID,
		Provider:            "bridge",
		ProviderRouteID:     providerRouteID,
		Kind:                "liquidation_address",
		SourceRail:          "solana",
		SourceCurrency:      "usdc",
		SourceAddress:       "So11111111111111111111111111111111111111112",
		DestinationRail:     "sui",
		DestinationCurrency: "usdc",
		DestinationAddrHash: utils.SHA256HexString("0xabc"),
		State:               "active",
		CreatedAt:           utils.NowUnix(),
		UpdatedAt:           utils.NowUnix(),
	}
	if err := testStore.CreateDepositRoute(context.Background(), dr); err != nil {
		t.Fatalf("create deposit route: %v", err)
	}

	got, err := testStore.GetDepositRoute(context.Background(), userID, "liquidation_address", "solana", "usdc")
	if err != nil {
		t.Fatalf("get deposit route: %v", err)
	}
	if got == nil {
		t.Fatal("expected deposit route, got nil")
	}
	if got.ProviderRouteID != providerRouteID {
		t.Fatalf("expected provider route id %s, got %s", providerRouteID, got.ProviderRouteID)
	}
	if got.SourceAddress != "So11111111111111111111111111111111111111112" {
		t.Fatalf("expected source address, got %s", got.SourceAddress)
	}
}

func TestStoreDepositRoute_CreateIdempotent(t *testing.T) {
	userID := insertTestUser(t)
	providerRouteID := utils.NewID()
	now := utils.NowUnix()

	dr := &deposit.DepositRoute{
		ID:                  utils.NewID(),
		UserID:              userID,
		Provider:            "bridge",
		ProviderRouteID:     providerRouteID,
		Kind:                "liquidation_address",
		SourceRail:          "evm",
		SourceCurrency:      "usdc",
		SourceAddress:       "0xaddr",
		DestinationRail:     "sui",
		DestinationCurrency: "usdc",
		DestinationAddrHash: "hash",
		State:               "active",
		CreatedAt:           now,
		UpdatedAt:           now,
	}
	if err := testStore.CreateDepositRoute(context.Background(), dr); err != nil {
		t.Fatalf("first create: %v", err)
	}

	dr2 := *dr
	dr2.ID = utils.NewID()
	if err := testStore.CreateDepositRoute(context.Background(), &dr2); err != nil {
		t.Fatalf("duplicate create: %v", err)
	}

	got, err := testStore.GetDepositRoute(context.Background(), userID, "liquidation_address", "evm", "usdc")
	if err != nil {
		t.Fatalf("get deposit route: %v", err)
	}
	if got == nil {
		t.Fatal("expected deposit route, got nil")
	}
	if got.ID != dr.ID {
		t.Fatal("ON CONFLICT DO NOTHING should preserve the first inserted row")
	}
}

func TestStoreDepositRoute_GetByProviderRouteID(t *testing.T) {
	userID := insertTestUser(t)
	providerRouteID := utils.NewID()

	insertTestDepositRoute(t, userID, providerRouteID, "virtual_account", "fiat", "usd", "")

	got, err := testStore.GetDepositRouteByProviderRouteID(context.Background(), providerRouteID)
	if err != nil {
		t.Fatalf("get deposit route by provider route id: %v", err)
	}
	if got == nil {
		t.Fatal("expected deposit route, got nil")
	}
	if got.UserID != userID {
		t.Fatalf("expected user id %s, got %s", userID, got.UserID)
	}
}

func TestStoreDepositRoute_GetByProviderRouteID_NotFound(t *testing.T) {
	got, err := testStore.GetDepositRouteByProviderRouteID(context.Background(), utils.NewID())
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if got != nil {
		t.Fatal("expected nil for unknown provider route id")
	}
}

func TestStoreWebhookEvent_InsertAndExists(t *testing.T) {
	eventID := utils.NewID()
	providerEventID := utils.NewID()

	ev := &deposit.BridgeWebhookEvent{
		ID:              eventID,
		ProviderEventID: providerEventID,
		EventType:       "kyc_link.approved",
		RawPayload:      []byte(`{"id":"test"}`),
		Processed:       false,
		CreatedAt:       utils.NowUnix(),
	}
	if err := testStore.InsertWebhookEvent(context.Background(), ev); err != nil {
		t.Fatalf("insert webhook event: %v", err)
	}

	exists, err := testStore.WebhookEventExists(context.Background(), providerEventID)
	if err != nil {
		t.Fatalf("check event exists: %v", err)
	}
	if !exists {
		t.Fatal("expected event to exist after insert")
	}
}

func TestStoreWebhookEvent_DoesNotExist(t *testing.T) {
	exists, err := testStore.WebhookEventExists(context.Background(), utils.NewID())
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if exists {
		t.Fatal("expected false for unknown provider event id")
	}
}

func TestStoreWebhookEvent_GetUnprocessed_And_MarkProcessed(t *testing.T) {
	eventID := utils.NewID()
	ev := &deposit.BridgeWebhookEvent{
		ID:              eventID,
		ProviderEventID: utils.NewID(),
		EventType:       "virtual_account.activity",
		RawPayload:      []byte(`{"data":{}}`),
		Processed:       false,
		CreatedAt:       utils.NowUnix(),
	}
	if err := testStore.InsertWebhookEvent(context.Background(), ev); err != nil {
		t.Fatalf("insert webhook event: %v", err)
	}

	events, err := testStore.GetUnprocessedWebhookEvents(context.Background(), 100)
	if err != nil {
		t.Fatalf("get unprocessed events: %v", err)
	}
	found := false
	for _, e := range events {
		if e.ID == eventID {
			found = true
			break
		}
	}
	if !found {
		t.Fatal("expected inserted event in unprocessed list")
	}

	if err := testStore.MarkWebhookEventProcessed(context.Background(), eventID); err != nil {
		t.Fatalf("mark processed: %v", err)
	}

	events, err = testStore.GetUnprocessedWebhookEvents(context.Background(), 100)
	if err != nil {
		t.Fatalf("get unprocessed events after mark: %v", err)
	}
	for _, e := range events {
		if e.ID == eventID {
			t.Fatal("event should not appear in unprocessed list after being marked processed")
		}
	}
}
