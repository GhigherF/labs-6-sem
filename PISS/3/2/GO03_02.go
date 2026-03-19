package main

import (
	"GO03_02/P03_02"
	"fmt"
	"net/http"
)

func main() {
	var counters = P03_02.Stats{0, 0}
	fmt.Println("Сервер запущен")
	http.HandleFunc("/S", func(w http.ResponseWriter, r *http.Request) {
		if r.Method == "GET" {
			counters.PlusGet()
			w.Write([]byte("+1 to GET"))
		} else {
			counters.PlusPost()
			w.Write([]byte("+1 to POST"))
		}
	})
	http.HandleFunc("/G", func(w http.ResponseWriter, r *http.Request) {
		if r.Method == "GET" {
			w.Header().Set("Content-Type", "text/plain; charset=utf-8")
			w.Write([]byte(counters.GenStr()))
		}
	})
	http.ListenAndServe(":3000", nil)
}
