package main

import (
	"database/sql"
	"encoding/json"
	"log"
	"net/http"
	"strconv"

	_ "BD/docs"

	"github.com/gorilla/mux"
	_ "github.com/jackc/pgx/v5/stdlib"
	httpSwagger "github.com/swaggo/http-swagger"
)

// @title Celebrities API
// @version 1.0
// @description API для управления знаменитостями
// @host localhost:2280
// @BasePath /

var db *sql.DB

// Звёзды крч
type Celebrity struct {
	Id           int    `json:"id"`
	FullName     string `json:"fullName"`
	Nationality  string `json:"nationality"`
	ReqPhotoPath string `json:"reqPhotoPath"`
}

// GetAllCelebrities godoc
// @Summary Получить всех знаменитостей
// @Description Возвращает список всех знаменитостей
// @Tags celebrities
// @Produce json
// @Success 200 {array} Celebrity
// @Router /celebrities/all [get]
func GetAllCelebrities(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	log.Println(r.Method + ": " + r.URL.Path)

	rows, err := db.Query("SELECT * FROM celebrities")
	if err != nil {
		log.Println(err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var celebs []Celebrity

	for rows.Next() {
		var celeb Celebrity

		err := rows.Scan(
			&celeb.Id,
			&celeb.FullName,
			&celeb.Nationality,
			&celeb.ReqPhotoPath,
		)

		if err != nil {
			log.Println(err)
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		celebs = append(celebs, celeb)
	}

	json.NewEncoder(w).Encode(celebs)
}

// GetCelebrityById godoc
// @Summary Получить знаменитость по id
// @Description Возвращает одну знаменитость
// @Tags celebrities
// @Produce json
// @Param id path int true "ID знаменитости"
// @Success 200 {object} Celebrity
// @Failure 404 {object} map[string]string
// @Failure 500 {string} string
// @Router /celebrities/{id} [get]
func GetCelebrityById(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	log.Println(r.Method + ": " + r.URL.Path)

	id := mux.Vars(r)["id"]

	var celeb Celebrity

	err := db.QueryRow(
		"SELECT * FROM celebrities WHERE id=$1",
		id,
	).Scan(
		&celeb.Id,
		&celeb.FullName,
		&celeb.Nationality,
		&celeb.ReqPhotoPath,
	)

	if err != nil {
		if err == sql.ErrNoRows {
			w.WriteHeader(http.StatusNotFound)

			json.NewEncoder(w).Encode(map[string]string{
				"message": "Не найдена знаменитость с id = " + id,
			})

			return
		}

		log.Println(err)

		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(celeb)
}

// CreateCelebrity godoc
// @Summary Создать знаменитость
// @Description Добавляет новую знаменитость
// @Tags celebrities
// @Accept json
// @Produce json
// @Param celebrity body Celebrity true "Celebrity object"
// @Success 201 {object} Celebrity
// @Failure 400 {string} string
// @Failure 500 {string} string
// @Router /celebrities [post]
func CreateCelebrity(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	log.Println(r.Method + ": " + r.URL.Path)

	var celeb Celebrity

	if err := json.NewDecoder(r.Body).Decode(&celeb); err != nil {
		log.Println(err)

		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	_, err := db.Exec(
		`INSERT INTO celebrities(id, full_name, nationality, req_photo_path)
		 VALUES ($1, $2, $3, $4)`,
		celeb.Id,
		celeb.FullName,
		celeb.Nationality,
		celeb.ReqPhotoPath,
	)

	if err != nil {
		log.Println(err)

		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)

	json.NewEncoder(w).Encode(celeb)
}

// UpdateCelebrity godoc
// @Summary Обновить знаменитость
// @Description Обновляет знаменитость по id
// @Tags celebrities
// @Accept json
// @Produce json
// @Param id path int true "ID знаменитости"
// @Param celebrity body Celebrity true "Celebrity object"
// @Success 200 {object} Celebrity
// @Failure 404 {object} map[string]string
// @Failure 500 {string} string
// @Router /celebrities/{id} [put]
func UpdateCelebrity(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	log.Println(r.Method + ": " + r.URL.Path)

	id := mux.Vars(r)["id"]

	var celeb Celebrity

	if err := json.NewDecoder(r.Body).Decode(&celeb); err != nil {
		log.Println(err)

		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	result, err := db.Exec(
		`UPDATE celebrities
		 SET full_name=$1,
		     nationality=$2,
		     req_photo_path=$3
		 WHERE id=$4`,
		celeb.FullName,
		celeb.Nationality,
		celeb.ReqPhotoPath,
		id,
	)

	if err != nil {
		log.Println(err)

		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		log.Println(err)

		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	if rowsAffected == 0 {
		w.WriteHeader(http.StatusNotFound)

		json.NewEncoder(w).Encode(map[string]string{
			"message": "Знаменитость с id = " + id + " не найдена",
		})

		return
	}

	celeb.Id, _ = strconv.Atoi(id)

	json.NewEncoder(w).Encode(celeb)
}

// DeleteCelebrity godoc
// @Summary Удалить знаменитость
// @Description Удаляет знаменитость по id
// @Tags celebrities
// @Produce json
// @Param id path int true "ID знаменитости"
// @Success 200 {object} map[string]string
// @Failure 404 {object} map[string]string
// @Failure 500 {string} string
// @Router /celebrities/{id} [delete]
func DeleteCelebrity(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	log.Println(r.Method + ": " + r.URL.Path)

	id := mux.Vars(r)["id"]

	result, err := db.Exec(
		`DELETE FROM celebrities WHERE id=$1`,
		id,
	)

	if err != nil {
		log.Println(err)

		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		log.Println(err)

		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	if rowsAffected == 0 {
		w.WriteHeader(http.StatusNotFound)

		json.NewEncoder(w).Encode(map[string]string{
			"message": "Знаменитость с id = " + id + " не найдена",
		})

		return
	}

	json.NewEncoder(w).Encode(map[string]string{
		"message": "Знаменитость с id = " + id + " удалена успешно",
	})
}

func main() {
	var err error

	connectionString := "postgres://postgres:321QaZ451@localhost:5432/PIS_5?sslmode=disable"

	db, err = sql.Open("pgx", connectionString)
	if err != nil {
		log.Fatal(err)
	}

	defer db.Close()

	if err := db.Ping(); err != nil {
		log.Fatal(err)
	}

	router := mux.NewRouter()

	router.HandleFunc(
		"/celebrities/all",
		GetAllCelebrities,
	).Methods("GET")

	router.HandleFunc(
		"/celebrities/{id}",
		GetCelebrityById,
	).Methods("GET")

	router.HandleFunc(
		"/celebrities",
		CreateCelebrity,
	).Methods("POST")

	router.HandleFunc(
		"/celebrities/{id}",
		UpdateCelebrity,
	).Methods("PUT")

	router.HandleFunc(
		"/celebrities/{id}",
		DeleteCelebrity,
	).Methods("DELETE")

	router.PathPrefix("/swagger/").Handler(
		httpSwagger.WrapHandler,
	)

	log.Println("Сервер запущен: http://localhost:2280")
	log.Println("Swagger UI: http://localhost:2280/swagger/index.html")

	log.Fatal(
		http.ListenAndServe(":2280", router),
	)
}
