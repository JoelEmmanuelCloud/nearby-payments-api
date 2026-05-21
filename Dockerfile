FROM golang:1.22-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o server ./cmd/api

FROM alpine:3.19

RUN addgroup -S app && adduser -S app -G app

WORKDIR /app

COPY --from=builder /app/server .
COPY --from=builder /app/internal/db/migrations ./internal/db/migrations

USER app

EXPOSE 8080

CMD ["./server"]
