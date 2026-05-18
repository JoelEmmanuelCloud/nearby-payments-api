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

	walletBindingHash := utils.SHA256HexString(wb.SuiAddress + ":" + wb.AuthScheme)

	avsInput := avs.LeafRegistrationInput{
		Label:             leafName,
		ParentName:        parentName,
		LeafName:          leafName + "." + parentName,
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

	now := utils.NowUnix()
	task := &NameOperationTask{
		ID:         utils.NewID(),
		UserID:     userID,
		SuiAddress: wb.SuiAddress,
		LeafName:   leafName,
		ParentName: parentName,
		Action:     "leaf_name.register_initial",
		Status:     "authorized",
		AuthTaskID: avsResult.Authorization.Nonce,
		CreatedAt:  now,
		UpdatedAt:  now,
	}

	if err := s.store.CreateTask(ctx, task); err != nil {
		return nil, fmt.Errorf("create task: %w", err)
	}

	return &RegisterLeafResponse{
		TaskID:     task.ID,
		LeafName:   leafName,
		ParentName: parentName,
		Status:     task.Status,
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
		TaskID:     task.ID,
		LeafName:   task.LeafName,
		ParentName: task.ParentName,
		Action:     task.Action,
		Status:     task.Status,
		TxDigest:   task.TxDigest,
		ErrorMsg:   task.ErrorMsg,
		CreatedAt:  task.CreatedAt,
		UpdatedAt:  task.UpdatedAt,
	}, nil
}
