// internal/service/email_service.go
package service

import (
	"fmt"
	"net/smtp"
	"os"
)

type EmailService interface {
	SendPasswordResetEmail(email, resetToken, userName string) error
}

type emailService struct {
	smtpHost     string
	smtpPort     string
	smtpUsername string
	smtpPassword string
	fromEmail    string
	frontendURL  string
}

func NewEmailService() EmailService {
	return &emailService{
		smtpHost:     getEnvOrDefault("SMTP_HOST", "smtp.gmail.com"),
		smtpPort:     getEnvOrDefault("SMTP_PORT", "587"),
		smtpUsername: os.Getenv("SMTP_USERNAME"),
		smtpPassword: os.Getenv("SMTP_PASSWORD"),
		fromEmail:    getEnvOrDefault("FROM_EMAIL", os.Getenv("SMTP_USERNAME")),
		frontendURL:  getEnvOrDefault("FRONTEND_URL", "http://localhost:3000"),
	}
}

func (s *emailService) SendPasswordResetEmail(email, resetToken, userName string) error {
	// Skip email sending if SMTP credentials are not configured
	if s.smtpUsername == "" || s.smtpPassword == "" {
		fmt.Printf("📧 Password reset email would be sent to: %s\n", email)
		fmt.Printf("🔗 Reset link: %s/reset-password?token=%s\n", s.frontendURL, resetToken)
		return nil
	}

	resetURL := fmt.Sprintf("%s/reset-password?token=%s", s.frontendURL, resetToken)
	
	subject := "Reset Your LissanAI Password"
	body := s.generatePasswordResetHTML(userName, resetURL)
	
	return s.sendEmail(email, subject, body)
}

func (s *emailService) sendEmail(to, subject, body string) error {
	auth := smtp.PlainAuth("", s.smtpUsername, s.smtpPassword, s.smtpHost)
	
	msg := fmt.Sprintf("To: %s\r\n"+
		"Subject: %s\r\n"+
		"MIME-Version: 1.0\r\n"+
		"Content-Type: text/html; charset=UTF-8\r\n"+
		"\r\n"+
		"%s", to, subject, body)
	
	addr := fmt.Sprintf("%s:%s", s.smtpHost, s.smtpPort)
	return smtp.SendMail(addr, auth, s.fromEmail, []string{to}, []byte(msg))
}

func (s *emailService) generatePasswordResetHTML(userName, resetURL string) string {
	return fmt.Sprintf(`
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Your Password</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #4F46E5; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
        .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }
        .button { display: inline-block; background: #4F46E5; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; margin: 20px 0; }
        .footer { text-align: center; margin-top: 30px; color: #666; font-size: 14px; }
        .warning { background: #FEF3C7; border: 1px solid #F59E0B; padding: 15px; border-radius: 5px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔐 LissanAI Password Reset</h1>
        </div>
        <div class="content">
            <h2>Hello %s,</h2>
            <p>We received a request to reset your password for your LissanAI account.</p>
            <p>Click the button below to reset your password:</p>
            
            <a href="%s" class="button">Reset My Password</a>
            
            <div class="warning">
                <strong>⚠️ Important:</strong>
                <ul>
                    <li>This link will expire in 1 hour for security reasons</li>
                    <li>If you didn't request this reset, please ignore this email</li>
                    <li>Never share this link with anyone</li>
                </ul>
            </div>
            
            <p>If the button doesn't work, copy and paste this link into your browser:</p>
            <p style="word-break: break-all; background: #e5e5e5; padding: 10px; border-radius: 3px;">%s</p>
            
            <p>Best regards,<br>The LissanAI Team</p>
        </div>
        <div class="footer">
            <p>This is an automated message. Please do not reply to this email.</p>
            <p>© 2025 LissanAI. All rights reserved.</p>
        </div>
    </div>
</body>
</html>`, userName, resetURL, resetURL)
}

func getEnvOrDefault(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}