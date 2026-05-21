package main

import (
	"context"
	"fmt"
	"os"

	"github.com/joho/godotenv"
	dbpkg "github.com/vaariance/nearby/internal/db"
)

func main() {
	_ = godotenv.Load()
	ctx := context.Background()
	pool, err := dbpkg.NewPool(ctx, os.Getenv("DATABASE_URL"))
	if err != nil {
		fmt.Println("pool:", err)
		os.Exit(1)
	}
	defer pool.Close()
	if err := dbpkg.Migrate(ctx, pool, "internal/db/migrations"); err != nil {
		fmt.Println("migrate:", err)
		os.Exit(1)
	}
	fmt.Println("migrations applied")
}
