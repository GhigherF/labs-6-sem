package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strconv"

	"github.com/gorilla/mux"
)

type Celebrity struct {
	Id           int    `json:"id"`
	FullName     string `json:"fullName"`
	Nationality  string `json:"nationality"`
	ReqPhotoPath string `json:"reqPhotoPath"`
}

func main() {
	data, err := os.ReadFile("Celebrities.json")
	if err != nil {
		log.Fatal(err)
	}

	var celebs []Celebrity
	json.Unmarshal(data, &celebs)
	router := mux.NewRouter()

	router.HandleFunc("/celebrities/all", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		log.Println(r.Method + ": " + r.URL.Path)
		log.Println(celebs)
		json.NewEncoder(w).Encode(celebs)
	}).Methods("GET")
	router.HandleFunc("/celebrities/{id}", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		log.Println(r.Method + ": " + r.URL.Path)
		var resp *Celebrity
		for i := range celebs {
			if strconv.Itoa(celebs[i].Id) == mux.Vars(r)["id"] {
				resp = &celebs[i]
			}
		}
		if resp == nil {
			w.WriteHeader(http.StatusNotFound)
			json.NewEncoder(w).Encode(map[string]string{"Message": "Не найдена знаменитость с id = " + mux.Vars(r)["id"]})
			log.Println("Не найдена знаменитость с id = " + mux.Vars(r)["id"])
		} else {
			log.Println(resp)
			json.NewEncoder(w).Encode(resp)
		}
	}).Methods("GET")
	router.HandleFunc("/celebrities", func(w http.ResponseWriter, r *http.Request) {
		var celeb *Celebrity
		log.Println(r.Method + ": " + r.URL.Path)
		err := json.NewDecoder(r.Body).Decode(&celeb)
		if err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			log.Panic("Bad Request")
			return
		}
		for i := range celebs {
			if celebs[i].Id == celeb.Id {
				w.Header().Set("Content-Type", "text/plain")
				w.WriteHeader(http.StatusConflict)
				w.Write([]byte("Знаменитость с заданным Id уже существует"))
				log.Println("Знаменитость с заданным Id уже существует")
				return
			}
		}
		celebs = append(celebs, *celeb)

		data, _ := json.Marshal(celebs)
		os.WriteFile("Celebrities.json", data, 0644)

		w.Header().Set("Content-Type", "application/json")
		log.Println(celeb)
		json.NewEncoder(w).Encode(celeb)

	}).Methods("POST")
	router.HandleFunc("/celebrities/{id}", func(w http.ResponseWriter, r *http.Request) {
		var celeb *Celebrity
		log.Println(r.Method + ": " + r.URL.Path)
		err := json.NewDecoder(r.Body).Decode(&celeb)
		if err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			log.Panic("Bad Request")
			return
		}

		var id, _ = strconv.Atoi(mux.Vars(r)["id"])
		for i := range celebs {
			if celebs[i].Id == id {
				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusOK)
				celebs[i].FullName = celeb.FullName
				celebs[i].Nationality = celeb.Nationality
				celebs[i].ReqPhotoPath = celeb.ReqPhotoPath
				json.NewEncoder(w).Encode(celebs[i])
				log.Println(celebs[i])
				return
			}
		}
		data, _ := json.Marshal(celebs)
		os.WriteFile("Celebrities.json", data, 0644)

		w.Header().Set("Content-Type", "text/plain")
		w.Write([]byte("Знаменитость с id = " + mux.Vars(r)["id"] + " не найдена"))
		log.Println("Знаменитость с id = " + mux.Vars(r)["id"] + " не найдена")

	}).Methods("PUT")
	router.HandleFunc("/celebrities/{id}", func(w http.ResponseWriter, r *http.Request) {
		var id, _ = strconv.Atoi(mux.Vars(r)["id"])
		log.Println(r.Method + ": " + r.URL.Path)
		for i := range celebs {
			if celebs[i].Id == id {
				if i == len(celebs)-1 {
					celebs = celebs[:i]
				} else if i == 0 {
					celebs = celebs[i+1:]
				} else {
					celebs = append(celebs[:i], celebs[i+1:]...)
				}
				data, _ := json.Marshal(celebs)
				os.WriteFile("Celebrities.json", data, 0644)
				w.Header().Set("Content-Type", "text/plain")
				w.WriteHeader(http.StatusOK)
				log.Println("Знаменитость с id=" + mux.Vars(r)["id"] + " удалена успешно")
				w.Write([]byte("Знаменитость с id=" + mux.Vars(r)["id"] + " удалена успешно"))
				return
			}
		}
		data, _ := json.Marshal(celebs)
		os.WriteFile("Celebrities.json", data, 0644)
		w.Header().Set("Content-Type", "text/plain")
		w.WriteHeader(http.StatusNotFound)
		log.Println("Знаменитость с id=" + mux.Vars(r)["id"] + " не найдена")
		w.Write([]byte("Знаменитость с id=" + mux.Vars(r)["id"] + " не найдена"))

	}).Methods("DELETE")
	router.PathPrefix("/").HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Println(r.Method + ": " + r.URL.Path)
	})
	log.Println("Сервер создан и запущен по адресу http://localhost:2280")
	http.ListenAndServe(":2280", router)
}
