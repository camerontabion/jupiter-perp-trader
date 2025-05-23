// Code generated by sqlc. DO NOT EDIT.
// versions:
//   sqlc v1.29.0
// source: one_time_codes.sql

package database

import (
	"context"
	"time"
)

const createOneTimeCode = `-- name: CreateOneTimeCode :one
INSERT INTO one_time_codes (email, code, expires_at)
VALUES ($1, $2, $3)
ON CONFLICT (email) DO UPDATE SET code = $2, expires_at = $3
RETURNING code
`

type CreateOneTimeCodeParams struct {
	Email     string    `json:"email"`
	Code      string    `json:"code"`
	ExpiresAt time.Time `json:"expires_at"`
}

func (q *Queries) CreateOneTimeCode(ctx context.Context, arg CreateOneTimeCodeParams) (string, error) {
	row := q.db.QueryRowContext(ctx, createOneTimeCode, arg.Email, arg.Code, arg.ExpiresAt)
	var code string
	err := row.Scan(&code)
	return code, err
}

const deleteOneTimeCode = `-- name: DeleteOneTimeCode :exec
DELETE FROM one_time_codes WHERE email = $1
`

func (q *Queries) DeleteOneTimeCode(ctx context.Context, email string) error {
	_, err := q.db.ExecContext(ctx, deleteOneTimeCode, email)
	return err
}

const getOneTimeCode = `-- name: GetOneTimeCode :one
SELECT email, code, expires_at, created_at, updated_at FROM one_time_codes WHERE email = $1
`

func (q *Queries) GetOneTimeCode(ctx context.Context, email string) (OneTimeCode, error) {
	row := q.db.QueryRowContext(ctx, getOneTimeCode, email)
	var i OneTimeCode
	err := row.Scan(
		&i.Email,
		&i.Code,
		&i.ExpiresAt,
		&i.CreatedAt,
		&i.UpdatedAt,
	)
	return i, err
}

const updateOneTimeCode = `-- name: UpdateOneTimeCode :exec
UPDATE one_time_codes SET code = $2 WHERE email = $1
`

type UpdateOneTimeCodeParams struct {
	Email string `json:"email"`
	Code  string `json:"code"`
}

func (q *Queries) UpdateOneTimeCode(ctx context.Context, arg UpdateOneTimeCodeParams) error {
	_, err := q.db.ExecContext(ctx, updateOneTimeCode, arg.Email, arg.Code)
	return err
}
