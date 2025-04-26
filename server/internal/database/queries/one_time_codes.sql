-- name: CreateOneTimeCode :one
INSERT INTO one_time_codes (email, code, expires_at)
VALUES ($1, $2, $3)
ON CONFLICT (email) DO UPDATE SET code = $2, expires_at = $3
RETURNING code;

-- name: GetOneTimeCode :one
SELECT * FROM one_time_codes WHERE email = $1;

-- name: DeleteOneTimeCode :exec
DELETE FROM one_time_codes WHERE email = $1;

-- name: UpdateOneTimeCode :exec
UPDATE one_time_codes SET code = $2 WHERE email = $1;
