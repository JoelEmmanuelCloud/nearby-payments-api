.PHONY: dev build test lint migrate setup

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

migrate:
	go run ./cmd/migrate
