package mail

import (
	"testing"

	"github.com/baroncurtin2/simplebank/util"
	"github.com/stretchr/testify/require"
)

func Test_GmailSender_SendEmail(t *testing.T) {
	config, err := util.LoadConfig("..")
	require.NoError(t, err)

	sender := NewGmailSender(config.EmailSenderName, config.EmailSenderAddress, config.EmailSenderPassword)

	subject := "A test email"
	content := `
	<h1>Hello world</h1>
	<p>This is a test message from <a href="http://techschoo.guru">Tech School</a></p>
	`

	to := []string{"baroncurtin2@gmail.com"}
	attachFiles := []string{"../README.md"}

	err = sender.SendEmail(subject, content, to, nil, nil, attachFiles)
	require.NoError(t, err)
}
