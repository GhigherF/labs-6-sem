package main

import (
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", Handler)
	log.Println("Сервер запущен")
	http.ListenAndServe(":3000", nil)

}

func Handler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		{
			if r.URL.Path == "/A" {
				log.Println("Путь раcпознан: GET /A")
			} else {
				if r.URL.Path == "/A/B" {
					log.Println("Путь распознан: GET /A/B")
				} else {
					log.Println("Путь НЕ распознан : GET: ", r.URL.Path)
				}
			}
			break
		}
	case "POST":
		{
			if r.URL.Path == "/A" {
				log.Println("Путь раcпознан: POST /A")
			} else {
				if r.URL.Path == "/A/B" {
					log.Println("Путь распознан: POST /A/B")
				} else {
					log.Println("Путь НЕ распознан : POST: ", r.URL.Path)
				}
			}
			break
		}
	case "PUT":
		{
			if r.URL.Path == "/A" {
				log.Println("Путь раcпознан: PUT /A")
			} else {
				if r.URL.Path == "/A/B" {
					log.Println("Путь распознан: PUT /A/B")
				} else {
					log.Println("Путь НЕ распознан : PUT:", r.URL.Path)
				}
			}
			break
		}
	case "DELETE":
		{
			if r.URL.Path == "/A" {
				log.Println("Путь раcпознан: DELETE /A")
			} else {
				if r.URL.Path == "/A/B" {
					log.Println("Путь распознан: DELETE /A/B")
				} else {
					log.Println("Путь НЕ распознан : DELETE: ", r.URL.Path)
				}
			}
		}
		w.WriteHeader(200)
		w.Write([]byte("Logged"))
	}
}
