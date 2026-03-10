package main

import (
	"02/lib"
	"fmt"
	"net/http"
)

var A01 int = 3

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != "GET" {
			w.Header().Set("content-type", "text/html; charset=utf-8")
			w.WriteHeader(http.StatusMethodNotAllowed)
			w.Write([]byte("<h1>405 Method Not Allowed</h1>"))
		} else {
			w.Header().Set("Content-Type", "text/html")
			w.WriteHeader(200)
			w.Write([]byte(fmt.Sprintf(`
<h1>A01 = %d</h1>
<h1>A02 = %t</h1>
<h1>A03 = %s</h1>
`, A01, A02, lib.A03)))
		}
	})
	fmt.Println("Сервер запущен на http://localhost:4000")
	http.ListenAndServe(":4000", nil)
}
