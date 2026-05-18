package names

import (
	"context"
	"fmt"
	"regexp"
	"strings"

	"github.com/JoelEmmanuelCloud/nearby-payments-api/internal/avs"
	"github.com/JoelEmmanuelCloud/nearby-payments-api/internal/domain/auth"
	"github.com/JoelEmmanuelCloud/nearby-payments-api/internal/utils"
)

var leafNameRe = regexp.MustCompile(`^[a-z0-9][a-z0-9\-]{0,61}[a-z0-9]$|^[a-z0-9]$`)

type ServiceDeps struct {
	Store     *Store
	AuthStore *auth.Store
	AVSClient *avs.Client
}

type Service struct {
	store     *Store
	authStore *auth.Store
	avsClient *avs.Client
}

func NewService(deps ServiceDeps) *Service {
	return &Service{
		store:     deps.Store,
		authStore: deps.AuthStore,
		avsClient: deps.AVSClient,
	}
}

func (s *Service) RegisterLeaf(ctx context.Context, userID string, req RegisterLeafRequest) (*RegisterLeafResponse, error) {
	leafName := strings.ToLower(strings.TrimSpace(req.LeafName))
	parentName := strings.TrimSpace(req.ParentName)

	if !leafNameRe.MatchString(leafName) {
		return nil, ErrNameInvalid
	}
	if parentName == "" {
		return nil, ErrParentInvalid
	}

	wb, err := s.authStore.GetWalletBinding(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("get wallet binding: %w", err)
	}
	if wb == nil {
		return nil, ErrNoWalletBound
	}

	fullName := leafName + "." + parentName
	nameHash := "0x" + utils.SHA256HexString(fullName)
	walletBindingHash := utils.SHA256HexString(wb.SuiAddress + ":" + wb.AuthScheme)

	avsInput := avs.LeafRegistrationInput{
		Label:             leafName,
		ParentName:        parentName,
		LeafName:          fullName,
		UserAddress:       wb.SuiAddress,
		WalletBindingHash: walletBindingHash,
	}

	avsResult, err := s.avsClient.AuthorizeLeafRegistration(avsInput)
	if err != nil {
		return nil, ErrAVSUnauthorized
	}
	if avsResult.Status != "authorized" {
		return nil, ErrAVSUnauthorized
	}

	expiresAt := avsResult.Authorization.ExpiresAtMs / 1000
	now := utils.NowUnix()

	task := &NameOperationTask{
		ID:          utils.NewID(),
		UserID:      userID,
		Action:      "leaf_name.register_initial",
		PayloadHash: nameHash,
		Nonce:       avsResult.Authorization.Nonce,
		Status:      "authorized",
		AVSTaskID:   avsResult.Authorization.SignerSetID,
		CreatedAt:   now,
		UpdatedAt:   now,
		ExpiresAt:   expiresAt,
	}

	if err := s.store.CreateTask(ctx, task); err != nil {
		return nil, fmt.Errorf("create task: %w", err)
	}

	return &RegisterLeafResponse{
		TaskID:    task.ID,
		NameHash:  nameHash,
		Action:    task.Action,
		Status:    task.Status,
		ExpiresAt: task.ExpiresAt,
	}, nil
}

func (s *Service) GetTask(ctx context.Context, taskID, userID string) (*GetTaskResponse, error) {
	task, err := s.store.GetTaskByID(ctx, taskID)
	if err != nil {
		return nil, fmt.Errorf("get task: %w", err)
	}
	if task == nil || task.UserID != userID {
		return nil, ErrTaskNotFound
	}

	return &GetTaskResponse{
		TaskID:    task.ID,
		NameHash:  task.PayloadHash,
		Action:    task.Action,
		Status:    task.Status,
		CreatedAt: task.CreatedAt,
		UpdatedAt: task.UpdatedAt,
		ExpiresAt: task.ExpiresAt,
	}, nil
}
