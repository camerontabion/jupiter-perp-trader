package handlers

import (
	"math/rand"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	database "jupiter-perp-trader/internal/database/generated"
	"jupiter-perp-trader/internal/emailer"
	"jupiter-perp-trader/internal/jwt"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

const OneTimeCodeLifetime = time.Hour * 24 * 15 // 15 days

type RequestLoginBody struct {
	Email string `json:"email"`
}

func (h *Handlers) RequestLogin(c *gin.Context) {
	var requestBody RequestLoginBody
	if err := c.ShouldBindJSON(&requestBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// * Generate a random code and store it in the database
	code := ""
	for range 6 {
		code += strconv.Itoa(rand.Intn(10))
	}

	code, err := h.Db.CreateOneTimeCode(c, database.CreateOneTimeCodeParams{
		Email:     requestBody.Email,
		Code:      code,
		ExpiresAt: time.Now().Add(OneTimeCodeLifetime),
	})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// * Send the code to the user's email
	vars := emailer.OneTimePasswordVars{
		Code: code,
	}
	err = h.Emailer.Send(requestBody.Email, emailer.OneTimePasswordEmail, vars)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "One-Time Password sent"})
}

type LoginBody struct {
	Email string `json:"email"`
	Code  string `json:"code"`
}

func (h *Handlers) Login(c *gin.Context) {
	var requestBody LoginBody
	if err := c.ShouldBindJSON(&requestBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// * Verify the one-time code, and delete it from the database
	code, err := h.Db.GetOneTimeCode(c, requestBody.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid code"})
		return
	}
	if code.Code != requestBody.Code || code.ExpiresAt.Before(time.Now()) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid code"})
		return
	}
	err = h.Db.DeleteOneTimeCode(c, requestBody.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// * Create a new user if they don't exist
	user, err := h.Db.GetUserByEmail(c, requestBody.Email)
	if err != nil {
		user, err = h.Db.CreateUser(c, requestBody.Email)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
	}

	// * Create a new session
	sessionId, err := h.Db.CreateSession(c, database.CreateSessionParams{
		UserID: user.ID,
		Ip:     c.ClientIP(),
	})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// * Create a refresh token for the user and set cookie
	refreshToken, err := jwt.GenerateRefreshToken(sessionId)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	secure := os.Getenv("GIN_MODE") != "debug"
	c.SetCookie("refresh_token", refreshToken, int(jwt.RefreshTokenExpirationTime.Seconds()), "/", "", secure, true)

	// * Create a access token for the user
	accessToken, err := jwt.GenerateAccessToken(user.ID, user.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"accessToken": accessToken})
}

func (h *Handlers) clearRefreshToken(c *gin.Context) {
	clearCookie := func(c *gin.Context) {
		secure := os.Getenv("GIN_MODE") != "debug"
		c.SetCookie("refresh_token", "", -1, "/", "", secure, true)
	}

	// Delete session from the database and clear cookie
	refreshToken, err := c.Cookie("refresh_token")
	if err != nil {
		clearCookie(c)
		return
	}
	claims, err := jwt.ParseRefreshToken(refreshToken)
	if err != nil {
		clearCookie(c)
		return
	}
	sessionIdString := (*claims)["session_id"].(string)
	sessionId, err := uuid.Parse(sessionIdString)
	if err != nil {
		clearCookie(c)
		return
	}
	h.Db.DeleteSession(c, sessionId)
	clearCookie(c)
}

func (h *Handlers) Logout(c *gin.Context) {
	h.clearRefreshToken(c)
	c.JSON(http.StatusNoContent, gin.H{})
}

func (h *Handlers) LogoutAllSessions(c *gin.Context) {
	clearCookie := func(c *gin.Context) {
		secure := os.Getenv("GIN_MODE") != "debug"
		c.SetCookie("refresh_token", "", -1, "/", "", secure, true)
	}

	refreshToken, err := c.Cookie("refresh_token")
	if err != nil {
		clearCookie(c)
		return
	}
	claims, err := jwt.ParseRefreshToken(refreshToken)
	if err != nil {
		clearCookie(c)
		return
	}
	sessionIdString := (*claims)["session_id"].(string)
	sessionId, err := uuid.Parse(sessionIdString)
	if err != nil {
		clearCookie(c)
		return
	}
	session, err := h.Db.GetSession(c, sessionId)
	if err != nil {
		clearCookie(c)
		return
	}
	h.Db.DeleteAllSessionsForUser(c, session.UserID)
	clearCookie(c)
	c.JSON(http.StatusNoContent, gin.H{})
}

func (h *Handlers) Refresh(c *gin.Context) {
	onError := func(c *gin.Context) {
		h.clearRefreshToken(c)
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token!"})
		c.Abort()
	}

	// Verify the refresh token
	refreshToken, err := c.Cookie("refresh_token")
	if err != nil {
		onError(c)
		return
	}
	claims, err := jwt.ParseRefreshToken(refreshToken)
	if err != nil {
		onError(c)
		return
	}

	// Get the session ID from the refresh token
	sessionIdString := (*claims)["session_id"].(string)
	sessionId, err := uuid.Parse(sessionIdString)
	if err != nil {
		onError(c)
		return
	}
	session, err := h.Db.GetSession(c, sessionId)
	if err != nil {
		onError(c)
		return
	}

	// Get the user from the session
	user, err := h.Db.GetUserByID(c, session.UserID)
	if err != nil {
		onError(c)
		return
	}

	// Generate a new refresh token
	newRefreshToken, err := jwt.GenerateRefreshToken(session.ID)
	if err != nil {
		onError(c)
		return
	}
	secure := os.Getenv("GIN_MODE") != "debug"
	c.SetCookie("refresh_token", newRefreshToken, int(jwt.RefreshTokenExpirationTime.Seconds()), "/", "", secure, true)

	// Generate a new access token
	newAccessToken, err := jwt.GenerateAccessToken(session.UserID, user.Email)
	if err != nil {
		onError(c)
		return
	}

	c.JSON(http.StatusOK, gin.H{"accessToken": newAccessToken})
}

func (h *Handlers) TokenValidator() gin.HandlerFunc {
	return func(c *gin.Context) {
		token := c.GetHeader("Authorization")
		token = strings.Replace(token, "Bearer ", "", 1)
		if token == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "No token provided"})
			c.Abort()
			return
		}

		accessToken, err := jwt.ParseAccessToken(token)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
			c.Abort()
			return
		}
		userIdString := (*accessToken)["id"].(string)
		userEmail := (*accessToken)["email"].(string)
		c.Set("user_id", userIdString)
		c.Set("user_email", userEmail)

		c.Next()
	}
}
