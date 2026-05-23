.PHONY: dev build test lint setup

setup:
	go mod tidy

dev:
	air -c .air.toml

build:
	go build -o bin/api ./cmd/api

test:
	go test ./...

lint:
	golangci-lint run ./...
