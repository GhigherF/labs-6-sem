package main

import (
	"encoding/json"
	"strconv"

	"github.com/gorilla/mux"

	"log"
	"net/http"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type Celebrity struct {
	ID           int    `json:"id" gorm:"primaryKey"`
	FullName     string `json:"fullName"`
	Nationality  string `json:"nationality"`
	ReqPhotoPath string `json:"reqPhotoPath"`
}

func main() {
	router := mux.NewRouter()
	connectionString := "host=localhost user=postgres password=321QaZ451 dbname=PIS_5 port=5432 sslmode=disable"
	db, err := gorm.Open(postgres.Open(connectionString), &gorm.Config{})
	if err != nil {
		log.Fatal(err)
	}

	router.HandleFunc("/celebrities/all", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		log.Println(r.Method + ": " + r.URL.Path)
		var celebs []Celebrity
		rows := db.Find(&celebs)
		if rows.Error != nil {
			log.Fatal(err)
			return
		}
		log.Println(celebs)
		json.NewEncoder(w).Encode(celebs)
	}).Methods("GET")
	router.HandleFunc("/celebrities/{id}", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		log.Println(r.Method + ": " + r.URL.Path)
		id := mux.Vars(r)["id"]
		var celeb Celebrity
		result := db.First(&celeb, id)

		if result.Error != nil {
			w.WriteHeader(http.StatusNotFound)
			json.NewEncoder(w).Encode(map[string]string{
				"message": "Не найдена знаменитость с id = " + id,
			})
			return
		}

		log.Println(celeb)
		json.NewEncoder(w).Encode(celeb)

	}).Methods("GET")
	router.HandleFunc("/celebrities", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		log.Println(r.Method + ": " + r.URL.Path)
		var celeb Celebrity
		if err := json.NewDecoder(r.Body).Decode(&celeb); err != nil {
			http.Error(w, "Invalid JSON", http.StatusBadRequest)
			log.Println("Decode error:", err)
			return
		}

		result := db.Create(&celeb)

		if result.Error != nil {
			log.Println("DB error:", err)
			http.Error(w, "Database error", http.StatusInternalServerError)
			w.Header().Set("Content-Type", "text/plain")
			w.Write([]byte(err.Error()))
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(celeb)

	}).Methods("POST")
	router.HandleFunc("/celebrities/{id}", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		log.Println(r.Method + ": " + r.URL.Path)
		id := mux.Vars(r)["id"]
		var celeb Celebrity

		if err := db.First(&celeb, id).Error; err != nil {
			w.WriteHeader(http.StatusNotFound)
			json.NewEncoder(w).Encode(map[string]string{
				"message": "Знаменитость с id = " + id + " не найдена",
			})
			return
		}

		if err := json.NewDecoder(r.Body).Decode(&celeb); err != nil {
			http.Error(w, "Invalid JSON", http.StatusBadRequest)
			log.Println("Decode error:", err)
			return
		}
		celeb.ID, _ = strconv.Atoi(id)
		result := db.Save(&celeb)
		if result.Error != nil {
			log.Println("DB error:", err)
			http.Error(w, "Database error", http.StatusInternalServerError)
			w.Header().Set("Content-Type", "text/plain")
			w.Write([]byte(err.Error()))
			return
		}
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(celeb)
		log.Println(celeb)
	}).Methods("PUT")
	router.HandleFunc("/celebrities/{id}", func(w http.ResponseWriter, r *http.Request) {
		log.Println(r.Method + ": " + r.URL.Path)
		id := mux.Vars(r)["id"]
		result := db.Delete(&Celebrity{}, id)

		if result.RowsAffected == 0 {
			w.WriteHeader(http.StatusNotFound)
			json.NewEncoder(w).Encode(map[string]string{
				"message": "Знаменитость с id = " + id + " не найдена",
			})
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]string{
			"message": "Знаменитость с id = " + id + " удалена успешно",
		})

		log.Println("Deleted id =", id)
	}).Methods("DELETE")
	log.Println("Сервер создан и запущен по адресу http://localhost:2280")
	http.ListenAndServe(":2280", router)
}
