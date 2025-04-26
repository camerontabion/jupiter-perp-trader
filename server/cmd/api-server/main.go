package main

import (
	"log"
	"os"

	"database/sql"
	"jupiter-perp-trader/cmd/api-server/handlers"
	database "jupiter-perp-trader/internal/database/generated"
	"jupiter-perp-trader/internal/emailer"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	_ "github.com/joho/godotenv/autoload"
	_ "github.com/lib/pq"
)

func main() {
	// * Database
	dbUrl := os.Getenv("POSTGRES_URL")
	if dbUrl == "" {
		log.Fatal("POSTGRES_URL is not set in the environment")
	}
	conn, err := sql.Open("postgres", dbUrl)
	if err != nil {
		log.Fatal("Failed to connect to the database", err)
	}
	defer conn.Close()
	queries := database.New(conn)

	// * Emailer
	emailerClient, err := emailer.NewEmailer()
	if err != nil {
		log.Fatal("Failed to create email client", err)
	}

	// * Router
	router := gin.Default()
	router.Use(cors.Default())

	handler := &handlers.Handlers{
		Db:      queries,
		Emailer: emailerClient,
	}

	protected := router.Group("/")
	protected.Use(handler.TokenValidator())

	// Auth Routes
	router.POST("/auth/request-login", handler.RequestLogin)
	router.POST("/auth/login", handler.Login)
	router.POST("/auth/refresh", handler.Refresh)
	router.POST("/auth/logout", handler.Logout)
	router.POST("/auth/logout-all-sessions", handler.LogoutAllSessions)

	port := os.Getenv("PORT")
	if port == "" {
		log.Fatal("PORT is not set in the environment")
	}
	router.Run(":" + port)
}
