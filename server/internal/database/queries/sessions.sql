-- name: CreateSession :one
INSERT INTO sessions (user_id, ip) VALUES ($1, $2) RETURNING id;

-- name: DeleteSession :exec
DELETE FROM sessions WHERE id = $1;

-- name: DeleteAllSessionsForUser :exec
DELETE FROM sessions WHERE user_id = $1;

-- name: GetSession :one
SELECT * FROM sessions WHERE id = $1;
