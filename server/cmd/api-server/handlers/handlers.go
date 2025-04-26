package handlers

import (
	database "jupiter-perp-trader/internal/database/generated"
	"jupiter-perp-trader/internal/emailer"
)

type Handlers struct {
	Db      *database.Queries
	Emailer *emailer.Emailer
}
