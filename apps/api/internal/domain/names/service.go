package names

import (
	"context"
	"encoding/base64"
	"fmt"
	"regexp"
	"strings"

	"github.com/vaariance/nearby/internal/avs"
	"github.com/vaariance/nearby/internal/domain/auth"
	apperr "github.com/vaariance/nearby/internal/errors"
	"github.com/vaariance/nearby/internal/sui"
	"github.com/vaariance/nearby/internal/utils"
)

const parentName = "variance"

var leafNameRe = regexp.MustCompile(`^[a-z0-9][a-z0-9\-]{0,61}[a-z0-9]$|^[a-z0-9]$`)

type ServiceDeps struct {
	Store     *Store
	AuthStore *auth.Store
	AVSClient *avs.Client
	SuiClient *sui.Client
	Sponsor   *sui.Sponsor
}

type Service struct {
	store     *Store
	authStore *auth.Store
	avsClient *avs.Client
	suiClient *sui.Client
	sponsor   *sui.Sponsor
}

func NewService(deps ServiceDeps) *Service {
	return &Service{
		store:     deps.Store,
		authStore: deps.AuthStore,
		avsClient: deps.AVSClient,
		suiClient: deps.SuiClient,
		sponsor:   deps.Sponsor,
	}
}

func (s *Service) RegisterLeaf(ctx context.Context, userID string, req RegisterLeafRequest) (*RegisterLeafResponse, error) {
	leafName := strings.ToLower(strings.TrimSpace(req.LeafName))

	if !leafNameRe.MatchString(leafName) {
		return nil, ErrNameInvalid
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

	existing, err := s.store.GetActiveTaskByPayloadHash(ctx, nameHash, utils.NowUnix())
	if err != nil {
		return nil, fmt.Errorf("check active task: %w", err)
	}
	if existing != nil {
		if existing.UserID != userID {
			return nil, ErrNameTaken
		}
		return &RegisterLeafResponse{
			TaskID:         existing.ID,
			NameHash:       existing.PayloadHash,
			Action:         existing.Action,
			Status:         existing.Status,
			SponsorAddress: s.sponsor.Address(),
			ExpiresAt:      existing.ExpiresAt,
		}, nil
	}

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
		TaskID:         task.ID,
		NameHash:       nameHash,
		Action:         task.Action,
		Status:         task.Status,
		SponsorAddress: s.sponsor.Address(),
		ExpiresAt:      task.ExpiresAt,
	}, nil
}

func (s *Service) SubmitLeafRegistration(ctx context.Context, taskID, userID string, req SubmitLeafRequest) (*SubmitLeafResponse, error) {
	task, err := s.store.GetTaskByID(ctx, taskID)
	if err != nil {
		return nil, fmt.Errorf("get task: %w", err)
	}
	if task == nil || task.UserID != userID {
		return nil, ErrTaskNotFound
	}
	if task.Status != "authorized" {
		return nil, ErrTaskNotSubmittable
	}
	if task.ExpiresAt < utils.NowUnix() {
		return nil, ErrTaskExpired
	}

	txBytes, err := base64.StdEncoding.DecodeString(req.TxBytes)
	if err != nil {
		return nil, apperr.ErrBadRequest
	}

	execResp, err := s.sponsor.SubmitSponsoredTransaction(ctx, txBytes, req.UserSignature)
	if err != nil {
		_ = s.store.UpdateTaskStatus(ctx, task.ID, "failed", utils.NowUnix())
		return nil, ErrRegistrationFailed
	}

	_ = s.store.UpdateTaskStatus(ctx, task.ID, "submitted", utils.NowUnix())

	return &SubmitLeafResponse{
		TaskID:   task.ID,
		TxDigest: execResp.Digest,
		Status:   "submitted",
	}, nil
}

func (s *Service) CheckAvailability(ctx context.Context, leafName string) (*NameAvailabilityResponse, error) {
	leafName = strings.ToLower(strings.TrimSpace(leafName))
	if !leafNameRe.MatchString(leafName) {
		return nil, ErrNameInvalid
	}

	fullName := leafName + "." + parentName + ".sui"
	nameHash := "0x" + utils.SHA256HexString(fullName)

	// SuiNS resolution needs the fully-qualified `.sui` name. `parentName` omits the TLD (it's used
	// as-is for the AVS + task hash), but the on-chain leaf is `<leaf>.<parent>.sui` — without the
	// suffix the resolver never matches a registered name and every name reads back as "available".
	address, err := s.suiClient.ResolveNameServiceAddress(ctx, fullName)
	if err != nil {
		return nil, ErrSuiNSUnavailable
	}

	available := address == ""
	if available {
		active, err := s.store.GetActiveTaskByPayloadHash(ctx, nameHash, utils.NowUnix())
		if err != nil {
			return nil, fmt.Errorf("check active task: %w", err)
		}
		if active != nil {
			available = false
		}
	}

	return &NameAvailabilityResponse{
		Name:      fullName,
		Available: available,
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
