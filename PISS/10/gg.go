package main

import (
	"context"
	"log"
	"net/http"

	"github.com/graph-gophers/graphql-go"
	"github.com/graph-gophers/graphql-go/relay"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

const schemaString = `
	type Celebrity {
		id: Int!
		fullName: String!
		nationality: String!
		reqPhotoPath: String!
	}

	type DeleteResult {
		message: String!
	}

	type Query {
		allCelebrities(): [Celebrity!]!
		celebrity(id: Int!): Celebrity
	}

	type Mutation {
		createCelebrity(fullName: String!, nationality: String!, reqPhotoPath: String!): Celebrity!
		updateCelebrity(id: Int!, fullName: String, nationality: String, reqPhotoPath: String): Celebrity!
		deleteCelebrity(id: Int!): DeleteResult!
	}
`

type CelebrityModel struct {
	ID           int    `gorm:"primaryKey;column:id;autoIncrement:false"`
	FullName     string `gorm:"column:full_name"`
	Nationality  string `gorm:"column:nationality"`
	ReqPhotoPath string `gorm:"column:req_photo_path"`
}

func (CelebrityModel) TableName() string {
	return "celebrities"
}

type celebrityResolver struct {
	m CelebrityModel
}

func (r *celebrityResolver) ID() int32            { return int32(r.m.ID) }
func (r *celebrityResolver) FullName() string     { return r.m.FullName }
func (r *celebrityResolver) Nationality() string  { return r.m.Nationality }
func (r *celebrityResolver) ReqPhotoPath() string { return r.m.ReqPhotoPath }

type deleteResultResolver struct {
	message string
}

func (r *deleteResultResolver) Message() string { return r.message }

type Resolver struct {
	db *gorm.DB
}

func (r *Resolver) AllCelebrities(ctx context.Context) ([]*celebrityResolver, error) {
	var models []CelebrityModel
	if err := r.db.Find(&models).Error; err != nil {
		return nil, err
	}

	resolvers := make([]*celebrityResolver, len(models))
	for i, m := range models {
		resolvers[i] = &celebrityResolver{m: m}
	}
	return resolvers, nil
}

func (r *Resolver) Celebrity(ctx context.Context, args struct{ ID int32 }) (*celebrityResolver, error) {
	var m CelebrityModel
	if err := r.db.First(&m, args.ID).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, nil
		}
		return nil, err
	}
	return &celebrityResolver{m: m}, nil
}

func (r *Resolver) CreateCelebrity(ctx context.Context, args struct {
	FullName     string
	Nationality  string
	ReqPhotoPath string
}) (*celebrityResolver, error) {

	var maxID int
	r.db.Model(&CelebrityModel{}).Select("COALESCE(MAX(id), 0)").Scan(&maxID)

	m := CelebrityModel{
		ID:           maxID + 1,
		FullName:     args.FullName,
		Nationality:  args.Nationality,
		ReqPhotoPath: args.ReqPhotoPath,
	}

	if err := r.db.Create(&m).Error; err != nil {
		return nil, err
	}
	return &celebrityResolver{m: m}, nil
}

func (r *Resolver) UpdateCelebrity(ctx context.Context, args struct {
	ID           int32
	FullName     *string
	Nationality  *string
	ReqPhotoPath *string
}) (*celebrityResolver, error) {
	var m CelebrityModel
	if err := r.db.First(&m, args.ID).Error; err != nil {
		return nil, err
	}

	if args.FullName != nil {
		m.FullName = *args.FullName
	}
	if args.Nationality != nil {
		m.Nationality = *args.Nationality
	}
	if args.ReqPhotoPath != nil {
		m.ReqPhotoPath = *args.ReqPhotoPath
	}

	if err := r.db.Save(&m).Error; err != nil {
		return nil, err
	}
	return &celebrityResolver{m: m}, nil
}

func (r *Resolver) DeleteCelebrity(ctx context.Context, args struct{ ID int32 }) (*deleteResultResolver, error) {
	result := r.db.Delete(&CelebrityModel{}, args.ID)
	if result.Error != nil {
		return nil, result.Error
	}

	if result.RowsAffected == 0 {
		return &deleteResultResolver{message: "Знаменитость с таким ID не найдена"}, nil
	}

	return &deleteResultResolver{message: "Знаменитость удалена успешно"}, nil
}

func main() {
	connectionString := "host=localhost user=postgres password=321QaZ451 dbname=PIS_5 port=5432 sslmode=disable"
	db, err := gorm.Open(postgres.Open(connectionString), &gorm.Config{})
	if err != nil {
		log.Fatal(err)
	}

	rootResolver := &Resolver{db: db}
	schema := graphql.MustParseSchema(schemaString, rootResolver)

	http.Handle("/query", &relay.Handler{Schema: schema})

	log.Println("Сервер запущен на http://localhost:2280/query")
	log.Fatal(http.ListenAndServe(":2280", nil))
}
