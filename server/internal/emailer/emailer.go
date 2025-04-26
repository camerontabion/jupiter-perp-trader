package emailer

import (
	"errors"
	"fmt"
	"os"
	"reflect"
	"strings"

	"github.com/resend/resend-go/v2"
)

func NewEmailer() (*Emailer, error) {
	resendApiKey := os.Getenv("RESEND_API_KEY")
	if resendApiKey == "" {
		return nil, errors.New("RESEND_API_KEY is not set")
	}

	return &Emailer{
		Client: resend.NewClient(resendApiKey),
	}, nil
}

func (e *Emailer) Send(to string, emailData EmailData, vars any) error {
	from := os.Getenv("FROM_EMAIL")
	if from == "" {
		return errors.New("FROM_EMAIL is not set")
	}

	_, err := e.Client.Emails.Send(&resend.SendEmailRequest{
		To:      []string{to},
		From:    from,
		Subject: emailData.Subject,
		Html:    emailData.Html(vars),
	})
	return err
}

// * Email templates
var (
	OneTimePasswordEmail = EmailData{
		Subject: "Jupiter Perp Trader - One-Time Password",
		Template: `
<html>
	<head>
		<title>Jupiter Perp Trader - One-Time Password</title>
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<style>
			body {
				font-family: Arial, sans-serif;
				background-color: #f4f4f4;
			}
		</style>
	</head>
	<body>
		<h1>Jupiter Perp Trader - One-Time Password</h1>
		<p>Your one-time password is: {{code}}</p>
	</body>
</html>
		`,
	}
)

type OneTimePasswordVars struct {
	Code string
}

type Emailer struct {
	Client *resend.Client
}

type EmailData struct {
	Subject  string
	Template string
}

func (e *EmailData) Html(vars any) string {
	return renderTemplate(e.Template, toMap(vars))
}

func renderTemplate(template string, vars map[string]any) string {
	html := template
	for key, value := range vars {
		html = strings.Replace(html, "{{"+key+"}}", fmt.Sprint(value), -1)
	}
	return html
}

// Converts a struct to a map[string]any using the field names as keys
func toMap[T any](v T) map[string]any {
	out := make(map[string]any)
	val := reflect.ValueOf(v)
	typ := reflect.TypeOf(v)

	for i := 0; i < val.NumField(); i++ {
		// Use lowercase field name as template key
		key := strings.ToLower(typ.Field(i).Name)
		out[key] = val.Field(i).Interface()
	}
	return out
}
