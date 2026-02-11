package main

import (
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"
)

type PostRequestData struct {
	Op string  `json:"op"`
	X  float32 `json:"x"`
	Y  float32 `json:"y"`
}

type GetResponseData struct {
	Op     string  `json:"op"`
	X      float32 `json:"x"`
	Y      float32 `json:"y"`
	Result float32 `json:"result"`
}

func main() {
	var JSON *PostRequestData

	var server = chi.NewRouter()
	server.Get("/NGINX-test", func(w http.ResponseWriter, r *http.Request) {
		if JSON != nil {
			var response GetResponseData
			response.X = JSON.X
			response.Y = JSON.Y
			response.Op = JSON.Op

			switch response.Op {
			case "sub":
				response.Result = JSON.X - JSON.Y
			case "add":
				response.Result = JSON.X + JSON.Y
			case "mul":
				response.Result = JSON.X * JSON.Y
			case "div":
				response.Result = JSON.X / JSON.Y
			}
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(200)
			json.NewEncoder(w).Encode(response)
		} else {
			w.Header().Set("Content-Type", "text/plain")
			w.WriteHeader(404)
			w.Write([]byte("JSON не найден на сервере"))
		}
	})
	server.Post("/NGINX-test", func(w http.ResponseWriter, r *http.Request) {
		if JSON != nil {
			w.Header().Set("Content-Type", "text/plain")
			w.WriteHeader(409)
			w.Write([]byte("JSON уже хранится на сервере"))
		} else {
			var temp PostRequestData
			json.NewDecoder(r.Body).Decode(&temp)
			switch temp.Op {
			case "add", "mul", "div", "sub":
				{
					JSON = &temp
					w.Header().Set("Content-Type", "application/json")
					w.WriteHeader(200)
					json.NewEncoder(w).Encode(JSON)
				}
			default:
				{
					w.Header().Set("Content-Type", "text/plain")
					w.WriteHeader(403)
					w.Write([]byte("Неверная операция"))
				}
			}
		}
	})
	server.Put("/NGINX-test", func(w http.ResponseWriter, r *http.Request) {
		if JSON != nil {
			var response PostRequestData
			json.NewDecoder(r.Body).Decode(&response)
			switch response.Op {
			case "add", "mul", "div", "sub":
				{
					w.Header().Set("Content-Type", "application/json")
					w.WriteHeader(200)
					JSON = &response
					json.NewEncoder(w).Encode(response)
				}
			default:
				{
					w.Header().Set("Content-Type", "text/plain")
					w.WriteHeader(403)
					w.Write([]byte("Неверная операция"))
				}
			}
		} else {
			w.Header().Set("Content-Type", "text/plain")
			w.WriteHeader(404)
			w.Write([]byte("JSON не найден на сервере"))
		}
	})
	server.Delete("/NGINX-test", func(w http.ResponseWriter, r *http.Request) {
		if JSON != nil {
			JSON = nil
			w.Header().Set("Content-Type", "text/plain")
			w.WriteHeader(200)
			w.Write([]byte("JSON успешно удалён"))
		} else {
			w.Header().Set("Content-Type", "text/plain")
			w.WriteHeader(404)
			w.Write([]byte("JSON не найден на сервере"))
		}
	})

	http.ListenAndServe(":40000", server)
}
