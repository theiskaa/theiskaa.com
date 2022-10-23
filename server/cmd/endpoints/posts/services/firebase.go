//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

package posts

import (
	"io/ioutil"
	"net/http"

	"cloud.google.com/go/firestore"
	"firebase.google.com/go/auth"
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
	auth       *auth.Client
	collection *firestore.CollectionRef
}

// Set [PostsRepository] as [PostsFirebaseService].
var _ posts.PostsRepository = &PostsFirebaseService{}

// A creator function to generate the [PostsRepository] as [PostsFirebaseService].
func NewPostsFirebaseService(db *firestore.Client, auth *auth.Client) *PostsFirebaseService {
	return &PostsFirebaseService{db: db, collection: db.Collection("posts"), auth: auth}
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
	if _, err := pkg.VerifyFireToken(r.Header.Get("Authorization"), p.auth); err != nil {
		return nil, err
	}

	ctx := context.Background()

	reqBody, err := ioutil.ReadAll(r.Body)
	if err != nil {
		return nil, &pkg.InvalidRequestBody
	}

	transformedData := models.TransformPostBody(reqBody)

	// A new record at posts collection.
	doc := p.collection.NewDoc()

	// Pass the document's ID to the post model's ID.
	transformedData["id"] = doc.ID
	transformedData["date"] = pkg.Now()

	if _, writingErr := doc.Set(ctx, transformedData); writingErr != nil {
		appErr := pkg.FromFirebaseError(writingErr)
		return nil, &appErr
	}

	return transformedData, nil
}

func (p *PostsFirebaseService) Delete(r *http.Request) (interface{}, *pkg.AppError) {
	if _, err := pkg.VerifyFireToken(r.Header.Get("Authorization"), p.auth); err != nil {
		return nil, err
	}

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
	if _, err := pkg.VerifyFireToken(r.Header.Get("Authorization"), p.auth); err != nil {
		return nil, err
	}

	ctx := context.Background()

	id, field := mux.Vars(r)["id"], mux.Vars(r)["field"]
	if len(id) < 1 || len(field) < 1 || field == "id" {
		return nil, &pkg.InvalidRequestBody
	}

	reqBody, err := ioutil.ReadAll(r.Body)
	if err != nil {
		return nil, &pkg.InvalidRequestBody
	}

	transformed := models.TransformPostBody(reqBody)

	_, writingErr := p.collection.Doc(id).Set(ctx, transformed, firestore.Merge([]string{field}))
	if writingErr != nil {
		appErr := pkg.FromFirebaseError(writingErr)
		return nil, &appErr
	}

	return nil, nil
}
