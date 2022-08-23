//
// This source code is distributed under the terms of Bad Code License.
// You are forbidden from distributing software containing this code to
// end users, because it is bad.
//
package posts

import (
	"encoding/json"
	"io/ioutil"
	"net/http"

	"cloud.google.com/go/firestore"
	"github.com/gorilla/mux"
	"github.com/mitchellh/mapstructure"
	"golang.org/x/net/context"
	"google.golang.org/api/iterator"
	posts "theiskaa.com/cmd/endpoints/posts"
	models "theiskaa.com/cmd/endpoints/posts/models"
	"theiskaa.com/pkg"
)

type PostsFirebaseService struct {
	db         *firestore.Client
	collection *firestore.CollectionRef
}

// Set [PostsRepository] as [PostsFirebaseService].
var _ posts.PostsRepository = &PostsFirebaseService{}

// A creator function to generate the [PostsRepository] as [PostsFirebaseService].
func NewPostsFirebaseService(db *firestore.Client) *PostsFirebaseService {
	return &PostsFirebaseService{db: db, collection: db.Collection("posts")}
}

func (p *PostsFirebaseService) Fetch(r *http.Request) (interface{}, *pkg.AppError) {
	ctx := context.Background()

	var posts []models.Post

	iter := p.collection.Documents(ctx)
	defer iter.Stop()

	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}

		if err != nil {
			appErr := pkg.FromFirebaseError(err)
			return nil, &appErr
		}

		var post models.Post
		mapstructure.Decode(doc.Data(), &post)

		posts = append(posts, post)
	}

	return posts, nil
}

func (p *PostsFirebaseService) Get(r *http.Request) (interface{}, *pkg.AppError) {
	data, err := pkg.GetDocumentsData(*p.collection, mux.Vars(r)["id"])
	if err != nil {
		appErr := pkg.FromFirebaseError(err)
		return nil, &appErr
	}

	// Convert JSON map data to post model.
	var post models.Post
	mapstructure.Decode(data, &post)

	return post, nil
}

func (p *PostsFirebaseService) Add(r *http.Request) (interface{}, *pkg.AppError) {
	ctx := context.Background()

	reqBody, err := ioutil.ReadAll(r.Body)
	if err != nil {
		return nil, &pkg.InvalidRequestBody
	}

	// Unwrap the binary request body as map model.
	var postData map[string]interface{}
	json.Unmarshal(reqBody, &postData)

	// Decode the [postData] as post model structure.
	var post models.Post
	mapstructure.Decode(postData, &post)

	// A new record at posts collection.
	doc := p.collection.NewDoc()

	// Pass the document's ID to the post model's ID.
	post.ID = doc.ID

	if _, writingErr := doc.Set(ctx, post.ToJSON()); writingErr != nil {
		appErr := pkg.FromFirebaseError(writingErr)
		return nil, &appErr
	}

	return post, nil
}

func (p *PostsFirebaseService) Delete(r *http.Request) (interface{}, *pkg.AppError) {
	ctx := context.Background()

	id := mux.Vars(r)["id"]
	if len(id) < 1 {
		return nil, &pkg.InvalidRequestBody
	}

	if _, err := p.collection.Doc(id).Delete(ctx); err != nil {
		appErr := pkg.FromFirebaseError(err)
		return nil, &appErr
	}

	return nil, nil
}

func (p *PostsFirebaseService) Update(r *http.Request) (interface{}, *pkg.AppError) {
	ctx := context.Background()

	id, field := mux.Vars(r)["id"], mux.Vars(r)["field"]
	if len(id) < 1 || len(field) < 1 || field == "id" {
		return nil, &pkg.InvalidRequestBody
	}

	reqBody, err := ioutil.ReadAll(r.Body)
	if err != nil {
		return nil, &pkg.InvalidRequestBody
	}

	var postData map[string]interface{}
	json.Unmarshal(reqBody, &postData)

	_, writingErr := p.collection.Doc(id).Set(ctx, postData, firestore.Merge([]string{field}))
	if writingErr != nil {
		appErr := pkg.FromFirebaseError(writingErr)
		return nil, &appErr
	}

	return nil, nil
}
