package main

import (
	"log"
	"net/http"

	"golang.org/x/net/webdav"
)

func main() {
	handler := &webdav.Handler{
		Prefix:     "/webdav/",
		FileSystem: webdav.Dir("./data"),
		LockSystem: webdav.NewMemLS(),
	}

	log.Println("WebDav serverr on :3000")
	err := http.ListenAndServe(":3000", handler)
	if err != nil {
		log.Fatal(err)
	}
}
