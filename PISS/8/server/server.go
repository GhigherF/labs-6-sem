package main

import (
	"log"
	"net/http"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool { return true },
}

func main() {
	http.HandleFunc("/ws", func(w http.ResponseWriter, r *http.Request) {
		if conn, err := upgrader.Upgrade(w, r, nil); err == nil {
			defer conn.Close()
			for {
				msgType, msg, err := conn.ReadMessage()
				if err != nil {
					if websocket.IsUnexpectedCloseError(err, websocket.CloseNormalClosure) {
						log.Println("Websocket closed le normale")
					} else {
						log.Println("Read Errrorr:", err)
					}
					break
				} else {
					log.Println(string(msg))
					if err = conn.WriteMessage(msgType, []byte(string(msg)+"(From Server)")); err != nil {
						log.Println("Write Errrorr:", err)
					}
				}
			}
		} else {
			log.Println("upgrade", err)
		}
	})

	log.Fatal(http.ListenAndServe(":3000", nil))
}
