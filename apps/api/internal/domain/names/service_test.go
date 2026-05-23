package names_test

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"

	"github.com/go-chi/chi/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
	dbpkg "github.com/vaariance/nearby/internal/db"
	"github.com/vaariance/nearby/internal/domain/auth"
	"github.com/vaariance/nearby/internal/domain/names"
	"github.com/vaariance/nearby/internal/utils"
)

var (
	testPool      *pgxpool.Pool
	testAuthStore *auth.Store
	testStore     *names.Store
	testSvc       *names.Service
)

func TestMain(m *testing.M) {
	_ = godotenv.Load("../../../.env")
	ctx := context.Background()

	var err error
	testPool, err = dbpkg.NewPool(ctx, os.Getenv("DATABASE_URL"))
	if err != nil {
		panic("db pool: " + err.Error())
	}
	defer testPool.Close()

	testAuthStore = auth.NewStore(testPool)
	testStore = names.NewStore(testPool)
	testSvc = names.NewService(names.ServiceDeps{
		Store:     testStore,
		AuthStore: testAuthStore,
		AVSClient: nil,
	})

	os.Exit(m.Run())
}

func insertTestUser(t *testing.T) string {
	t.Helper()
	userID := utils.NewID()
	_, err := testPool.Exec(context.Background(),
		`INSERT INTO users (id, status, created_at, updated_at) VALUES ($1, 'active', $2, $2)`,
		userID, utils.NowUnix(),
	)
	if err != nil {
		t.Fatalf("insert test user: %v", err)
	}
	t.Cleanup(func() {
		testPool.Exec(context.Background(), `DELETE FROM name_operation_tasks WHERE user_id = $1`, userID)
		testPool.Exec(context.Background(), `DELETE FROM wallet_bindings WHERE user_id = $1`, userID)
		testPool.Exec(context.Background(), `DELETE FROM users WHERE id = $1`, userID)
	})
	return userID
}

func insertWalletBinding(t *testing.T, userID, suiAddress string) {
	t.Helper()
	now := utils.NowUnix()
	_, err := testPool.Exec(context.Background(),
		`INSERT INTO wallet_bindings (user_id, sui_address, auth_scheme, issuer, audience, created_at, updated_at)
		 VALUES ($1, $2, 'zklogin', 'https://accounts.google.com', 'test-client', $3, $3)`,
		userID, suiAddress, now,
	)
	if err != nil {
		t.Fatalf("insert wallet binding: %v", err)
	}
}

func newTestHandler() *names.Handler {
	return names.NewHandler(testSvc)
}

func testSessionContext(userID string) *auth.SessionContext {
	return &auth.SessionContext{
		User:      &auth.User{ID: userID, Status: "active"},
		Device:    &auth.Device{ID: utils.NewID(), Status: "active"},
		Session:   &auth.Session{ID: utils.NewID()},
		Integrity: &auth.DeviceIntegrityRecord{},
	}
}

func TestRegisterLeaf_NoSession(t *testing.T) {
	handler := newTestHandler()
	body, _ := json.Marshal(map[string]string{"leafName": "alice", "parentName": "nearby"})
	req := httptest.NewRequest(http.MethodPost, "/v1/names/leaf", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()
	handler.RegisterLeaf(rr, req)

	if rr.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", rr.Code)
	}
}

func TestRegisterLeaf_MissingLeafName(t *testing.T) {
	userID := insertTestUser(t)
	handler := newTestHandler()

	body, _ := json.Marshal(map[string]string{"parentName": "nearby"})
	req := httptest.NewRequest(http.MethodPost, "/v1/names/leaf", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	req = req.WithContext(auth.WithSession(req.Context(), testSessionContext(userID)))
	rr := httptest.NewRecorder()
	handler.RegisterLeaf(rr, req)

	if rr.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d", rr.Code)
	}
}

func TestRegisterLeaf_MissingParentName(t *testing.T) {
	userID := insertTestUser(t)
	handler := newTestHandler()

	body, _ := json.Marshal(map[string]string{"leafName": "alice"})
	req := httptest.NewRequest(http.MethodPost, "/v1/names/leaf", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	req = req.WithContext(auth.WithSession(req.Context(), testSessionContext(userID)))
	rr := httptest.NewRecorder()
	handler.RegisterLeaf(rr, req)

	if rr.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d", rr.Code)
	}
}

func TestGetTask_NoSession(t *testing.T) {
	handler := newTestHandler()
	req := httptest.NewRequest(http.MethodGet, "/v1/names/tasks/some-id", nil)
	rr := httptest.NewRecorder()
	handler.GetTask(rr, req)

	if rr.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", rr.Code)
	}
}

func TestService_RegisterLeaf_InvalidLeafName(t *testing.T) {
	userID := insertTestUser(t)
	_, err := testSvc.RegisterLeaf(context.Background(), userID, names.RegisterLeafRequest{
		LeafName:   "Invalid Name!!!",
		ParentName: "nearby",
	})
	if !errors.Is(err, names.ErrNameInvalid) {
		t.Fatalf("expected ErrNameInvalid, got %v", err)
	}
}

func TestService_RegisterLeaf_EmptyParentName(t *testing.T) {
	userID := insertTestUser(t)
	_, err := testSvc.RegisterLeaf(context.Background(), userID, names.RegisterLeafRequest{
		LeafName:   "alice",
		ParentName: "",
	})
	if !errors.Is(err, names.ErrParentInvalid) {
		t.Fatalf("expected ErrParentInvalid, got %v", err)
	}
}

func TestService_RegisterLeaf_NoWalletBound(t *testing.T) {
	userID := insertTestUser(t)
	_, err := testSvc.RegisterLeaf(context.Background(), userID, names.RegisterLeafRequest{
		LeafName:   "alice",
		ParentName: "nearby",
	})
	if !errors.Is(err, names.ErrNoWalletBound) {
		t.Fatalf("expected ErrNoWalletBound, got %v", err)
	}
}

func TestService_RegisterLeaf_LeafNameTooShort(t *testing.T) {
	userID := insertTestUser(t)
	insertWalletBinding(t, userID, "0x"+utils.SHA256HexString(userID)[:62])
	_, err := testSvc.RegisterLeaf(context.Background(), userID, names.RegisterLeafRequest{
		LeafName:   "-bad",
		ParentName: "nearby",
	})
	if !errors.Is(err, names.ErrNameInvalid) {
		t.Fatalf("expected ErrNameInvalid for leading hyphen, got %v", err)
	}
}

func TestService_GetTask_NotFound(t *testing.T) {
	userID := insertTestUser(t)
	_, err := testSvc.GetTask(context.Background(), utils.NewID(), userID)
	if !errors.Is(err, names.ErrTaskNotFound) {
		t.Fatalf("expected ErrTaskNotFound, got %v", err)
	}
}

func TestService_GetTask_WrongUser(t *testing.T) {
	userID := insertTestUser(t)
	otherUserID := insertTestUser(t)
	now := utils.NowUnix()

	task := &names.NameOperationTask{
		ID:          utils.NewID(),
		UserID:      userID,
		Action:      "leaf_name.register_initial",
		PayloadHash: "0xhash",
		Nonce:       utils.NewID(),
		Status:      "authorized",
		AVSTaskID:   utils.NewID(),
		CreatedAt:   now,
		UpdatedAt:   now,
		ExpiresAt:   now + 3600,
	}
	if err := testStore.CreateTask(context.Background(), task); err != nil {
		t.Fatalf("create task: %v", err)
	}

	_, err := testSvc.GetTask(context.Background(), task.ID, otherUserID)
	if !errors.Is(err, names.ErrTaskNotFound) {
		t.Fatalf("expected ErrTaskNotFound for wrong user, got %v", err)
	}
}

func TestService_GetTask_Valid(t *testing.T) {
	userID := insertTestUser(t)
	now := utils.NowUnix()

	task := &names.NameOperationTask{
		ID:          utils.NewID(),
		UserID:      userID,
		Action:      "leaf_name.register_initial",
		PayloadHash: "0xdeadbeef",
		Nonce:       utils.NewID(),
		Status:      "authorized",
		AVSTaskID:   utils.NewID(),
		CreatedAt:   now,
		UpdatedAt:   now,
		ExpiresAt:   now + 3600,
	}
	if err := testStore.CreateTask(context.Background(), task); err != nil {
		t.Fatalf("create task: %v", err)
	}

	resp, err := testSvc.GetTask(context.Background(), task.ID, userID)
	if err != nil {
		t.Fatalf("get task: %v", err)
	}
	if resp.TaskID != task.ID {
		t.Fatalf("expected task id %s, got %s", task.ID, resp.TaskID)
	}
	if resp.Status != "authorized" {
		t.Fatalf("expected status authorized, got %s", resp.Status)
	}
	if resp.NameHash != "0xdeadbeef" {
		t.Fatalf("expected name hash 0xdeadbeef, got %s", resp.NameHash)
	}
}

func TestGetTask_Handler_Valid(t *testing.T) {
	userID := insertTestUser(t)
	now := utils.NowUnix()

	task := &names.NameOperationTask{
		ID:          utils.NewID(),
		UserID:      userID,
		Action:      "leaf_name.register_initial",
		PayloadHash: "0xhash",
		Nonce:       utils.NewID(),
		Status:      "authorized",
		AVSTaskID:   utils.NewID(),
		CreatedAt:   now,
		UpdatedAt:   now,
		ExpiresAt:   now + 3600,
	}
	if err := testStore.CreateTask(context.Background(), task); err != nil {
		t.Fatalf("create task: %v", err)
	}

	handler := newTestHandler()
	rctx := chi.NewRouteContext()
	rctx.URLParams.Add("id", task.ID)

	req := httptest.NewRequest(http.MethodGet, "/v1/names/tasks/"+task.ID, nil)
	req = req.WithContext(context.WithValue(
		auth.WithSession(req.Context(), testSessionContext(userID)),
		chi.RouteCtxKey, rctx,
	))
	rr := httptest.NewRecorder()
	handler.GetTask(rr, req)

	if rr.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d: %s", rr.Code, rr.Body.String())
	}
	var resp names.GetTaskResponse
	if err := json.NewDecoder(rr.Body).Decode(&resp); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if resp.TaskID != task.ID {
		t.Fatalf("expected task id %s, got %s", task.ID, resp.TaskID)
	}
}

func TestGetTask_Handler_NotFound(t *testing.T) {
	userID := insertTestUser(t)
	handler := newTestHandler()

	rctx := chi.NewRouteContext()
	rctx.URLParams.Add("id", utils.NewID())

	req := httptest.NewRequest(http.MethodGet, "/v1/names/tasks/unknown", nil)
	req = req.WithContext(context.WithValue(
		auth.WithSession(req.Context(), testSessionContext(userID)),
		chi.RouteCtxKey, rctx,
	))
	rr := httptest.NewRecorder()
	handler.GetTask(rr, req)

	if rr.Code != http.StatusNotFound {
		t.Fatalf("expected 404, got %d", rr.Code)
	}
}

func TestStore_CreateAndGetTask(t *testing.T) {
	userID := insertTestUser(t)
	now := utils.NowUnix()

	task := &names.NameOperationTask{
		ID:          utils.NewID(),
		UserID:      userID,
		Action:      "leaf_name.register_initial",
		PayloadHash: "0xabc",
		Nonce:       utils.NewID(),
		Status:      "authorized",
		AVSTaskID:   utils.NewID(),
		CreatedAt:   now,
		UpdatedAt:   now,
		ExpiresAt:   now + 7200,
	}
	if err := testStore.CreateTask(context.Background(), task); err != nil {
		t.Fatalf("create task: %v", err)
	}

	got, err := testStore.GetTaskByID(context.Background(), task.ID)
	if err != nil {
		t.Fatalf("get task: %v", err)
	}
	if got == nil {
		t.Fatal("expected task, got nil")
	}
	if got.UserID != userID {
		t.Fatalf("expected user id %s, got %s", userID, got.UserID)
	}
	if got.Nonce != task.Nonce {
		t.Fatalf("expected nonce %s, got %s", task.Nonce, got.Nonce)
	}
}

func TestStore_GetTask_NotFound(t *testing.T) {
	got, err := testStore.GetTaskByID(context.Background(), utils.NewID())
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if got != nil {
		t.Fatal("expected nil for unknown task id")
	}
}

func TestStore_UpdateTaskStatus(t *testing.T) {
	userID := insertTestUser(t)
	now := utils.NowUnix()

	task := &names.NameOperationTask{
		ID:          utils.NewID(),
		UserID:      userID,
		Action:      "leaf_name.register_initial",
		PayloadHash: "0xhash",
		Nonce:       utils.NewID(),
		Status:      "authorized",
		AVSTaskID:   utils.NewID(),
		CreatedAt:   now,
		UpdatedAt:   now,
		ExpiresAt:   now + 3600,
	}
	if err := testStore.CreateTask(context.Background(), task); err != nil {
		t.Fatalf("create task: %v", err)
	}

	if err := testStore.UpdateTaskStatus(context.Background(), task.ID, "submitted", now+1); err != nil {
		t.Fatalf("update task status: %v", err)
	}

	got, err := testStore.GetTaskByID(context.Background(), task.ID)
	if err != nil {
		t.Fatalf("get task: %v", err)
	}
	if got.Status != "submitted" {
		t.Fatalf("expected status submitted, got %s", got.Status)
	}
}
