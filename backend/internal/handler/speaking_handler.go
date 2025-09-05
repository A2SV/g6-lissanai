// internal/handler/conversation_handler.go

package handler

import (
	"bytes"
	"context"
	"encoding/json"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
	"lissanai.com/backend/internal/service"
)

var upgrader = websocket.Upgrader{
	CheckOrigin:     func(r *http.Request) bool { return true },
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
}

// ControlMessage defines incoming commands from the client.
type ControlMessage struct {
	Type string `json:"type"`
}

// ServerResponseMessage defines messages sent to the client for session control.
type ServerResponseMessage struct {
	Type   string `json:"type"`
	Reason string `json:"reason,omitempty"`
}

// ServerStatusMessage defines real-time status updates for the frontend.
type ServerStatusMessage struct {
	Status string `json:"status"` // e.g., "processing"
}

// ConversationHandler holds the dependencies.
type ConversationHandler struct {
	speakingService service.SpeakingService
}

// NewConversationHandler is the constructor.
func NewConversationHandler(s service.SpeakingService) *ConversationHandler {
	return &ConversationHandler{
		speakingService: s,
	}
}

// message is a private struct to pass websocket messages over a channel.
type message struct {
	msgType int
	payload []byte
}

// HandleConversation godoc
// @Summary Real-time AI Voice Conversation
// @Description Establishes a WebSocket for a real-time, voice-based conversation with an AI. The connection automatically terminates after 3 minutes.
// @Description
// @Description ### Conversation Lifecycle:
// @Description 1. **Connect**: The client establishes a WebSocket connection to this endpoint.
// @Description 2. **Speak**: The user speaks. The client continuously streams their voice as binary audio messages.
// @Description 3. **Pause**: The user stops speaking. After ~2-3 seconds of silence, the client sends a final text message.
// @Description 4. **Process**: The server receives the signal and immediately sends back a text message `{"status": "processing"}`. The frontend UI should update to show this.
// @Description 5. **Respond**: The server, after finishing the AI processing, sends the AI's spoken response back as a single binary audio message. The frontend plays this audio.
// @Description 6. **Repeat**: The process repeats from step 2.
// @Description 7. **Timeout**: The connection is automatically and forcefully closed by the server after 3 minutes.
// @Description
// @Description ### Client Responsibilities:
// @Description - **Must** stream user's voice as raw `BinaryMessage` chunks.
// @Description - **Must** implement silence detection (~2-3 seconds).
// @Description - **Must** send a `TextMessage` with the JSON `{"type": "end_of_speech"}` after detecting silence.
// @Description - **Must** handle incoming `TextMessage` status updates (e.g., `{"status": "processing"}`) to update the UI.
// @Description - **Must** be able to receive and play back `BinaryMessage` audio from the server.
// @Tags Conversation
// @Success 101 {string} string "Switching Protocols"
// @Router /ws/conversation [get]
func (h *ConversationHandler) HandleConversation(c *gin.Context) {
	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Println("Upgrade failed:", err)
		return
	}
	defer conn.Close()
	log.Println("Client connected. Session will auto-terminate in 3 minutes.")

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Minute)
	defer cancel()

	msgChan := make(chan message)
	errChan := make(chan error)
	go h.readMessages(conn, ctx, msgChan, errChan) // Using the helper function

	var audioBuffer bytes.Buffer

	for {
		select {
		case <-ctx.Done():
			log.Println("Conversation timeout reached. Closing connection.")
			timeoutMsg, _ := json.Marshal(ServerResponseMessage{Type: "end", Reason: "3_minute_limit"})
			// Use a deadline for writing the final message.
			conn.SetWriteDeadline(time.Now().Add(5 * time.Second))
			conn.WriteMessage(websocket.TextMessage, timeoutMsg)
			return

		case err := <-errChan:
			// Check if it's a normal closure, otherwise log the error.
			if !websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Println("WebSocket closed normally.")
			} else {
				log.Println("Read error:", err)
			}
			return

		case msg, ok := <-msgChan:
			if !ok {
				log.Println("Message channel closed by reader.")
				return
			}

			switch msg.msgType {
			case websocket.BinaryMessage:
				audioBuffer.Write(msg.payload)

			case websocket.TextMessage:
				var ctrlMsg ControlMessage
				if err := json.Unmarshal(msg.payload, &ctrlMsg); err == nil && ctrlMsg.Type == "end_of_speech" {
					if audioBuffer.Len() == 0 {
						log.Println("Received end_of_speech with no audio, skipping.")
						continue
					}
					log.Printf("End-of-speech received. Processing %d bytes.", audioBuffer.Len())

					// Step 1: Immediately send the "processing" status update.
					statusMsg, _ := json.Marshal(ServerStatusMessage{Status: "processing"})
					if err := conn.WriteMessage(websocket.TextMessage, statusMsg); err != nil {
						log.Println("Write error (could not send status update):", err)
						return
					}
					log.Println("Sent 'processing' status update to client.")

					// Step 2: Start the longer AI processing task.
					feedbackAudio, err := h.speakingService.ProcessAudioFeedback(ctx, audioBuffer.Bytes())
					if err != nil {
						if ctx.Err() != nil {
							log.Println("Processing cancelled due to conversation timeout.")
							return
						}
						log.Println("Processing error:", err)
						audioBuffer.Reset()
						continue // Don't kill the session for one bad turn.
					}

					// Step 3: Send the final AI audio response.
					if err := conn.WriteMessage(websocket.BinaryMessage, feedbackAudio); err != nil {
						log.Println("Write error (could not send AI response):", err)
						return
					}
					audioBuffer.Reset()
				}
			}
		}
	}
}

// readMessages is a helper function to run the blocking ReadMessage call in a goroutine.
func (h *ConversationHandler) readMessages(conn *websocket.Conn, ctx context.Context, msgChan chan<- message, errChan chan<- error) {
	defer close(msgChan)
	defer close(errChan)
	for {
		// Check if the context has been cancelled before trying to read.
		select {
		case <-ctx.Done():
			return
		default:
		}

		msgType, payload, err := conn.ReadMessage()
		if err != nil {
			// If the context is done, it's a planned closure, not an unexpected error.
			if ctx.Err() == nil {
				errChan <- err
			}
			return
		}
		msgChan <- message{msgType, payload}
	}
}