package main

import (
	"github.com/gorilla/websocket"
	"log"
	"strconv"
	"time"
)

func main() {

	conn, _, err := websocket.DefaultDialer.Dial("ws://localhost:3000/ws", nil)
	if err == nil {
		defer conn.Close()
		for i := 1; i <= 5; i++ {
			msg := []byte("from client:" + strconv.Itoa(i))
			if err := conn.WriteMessage(websocket.TextMessage, msg); err == nil {
				if _, reply, err := conn.ReadMessage(); err == nil {
					log.Println(string(reply))
				} else {
					log.Println("read:", err)
					break
				}
			} else {
				log.Println("write:", err)
				break
			}
			time.Sleep(1 * time.Second)
		}
	} else {
		log.Println("dial:", err)
	}
	conn.WriteMessage(websocket.CloseMessage,
		websocket.FormatCloseMessage(websocket.CloseNormalClosure, "Bye"))
}
