package jwt

import (
	"errors"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

const (
	AccessTokenExpirationTime  = time.Minute * 10
	RefreshTokenExpirationTime = time.Hour * 24 * 10
)

func GenerateAccessToken(id uuid.UUID, email string) (string, error) {
	claims := jwt.MapClaims{
		"id":    id,
		"email": email,
		"exp":   time.Now().Add(AccessTokenExpirationTime).Unix(),
	}
	return generateToken(claims, "ACCESS_TOKEN_SECRET")
}

func ParseAccessToken(tokenString string) (*jwt.MapClaims, error) {
	return parseToken(tokenString, "ACCESS_TOKEN_SECRET")
}

func GenerateRefreshToken(sessionID uuid.UUID) (string, error) {
	claims := jwt.MapClaims{
		"session_id": sessionID,
		"exp":        time.Now().Add(RefreshTokenExpirationTime).Unix(),
	}
	return generateToken(claims, "REFRESH_TOKEN_SECRET")
}

func ParseRefreshToken(tokenString string) (*jwt.MapClaims, error) {
	return parseToken(tokenString, "REFRESH_TOKEN_SECRET")
}

func generateToken(claims jwt.MapClaims, secretName string) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(os.Getenv(secretName)))
	if err != nil {
		return "", err
	}
	return tokenString, nil
}

func parseToken(tokenString string, secretName string) (*jwt.MapClaims, error) {
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (any, error) {
		return []byte(os.Getenv(secretName)), nil
	})
	if err != nil {
		return nil, err
	}
	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok || !token.Valid {
		return nil, errors.New("invalid token")
	}
	return &claims, nil
}
