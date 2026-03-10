package main

import (
	"01/lib"
	"fmt"
	"net/http"
)

const CO1 = 3.14

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
<h1>C01 = %e</h1>
<h1>C02 = %e</h1>
<h1>C03 = %e</h1>
`, CO1, CO2, lib.CO3)))
		}
	})
	fmt.Println("Сервер запущен на http://localhost:3000")
	http.ListenAndServe(":3000", nil)
}
