//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

package posts

import (
	"net/http"

	"github.com/gorilla/mux"
	"theiskaa.com/cmd/endpoints"
	"theiskaa.com/pkg"
)

type PostsRepository interface {
	// Fetches the all(or limited manually) posts.
	Fetch(r *http.Request) (interface{}, *pkg.AppError)

	// Gets only one post, by defining it via its ID.
	Get(r *http.Request) (interface{}, *pkg.AppError)

	// Creates a new post at posts collection.
	Add(r *http.Request) (interface{}, *pkg.AppError)

	// Deletes the exiting post from posts collection.
	Delete(r *http.Request) (interface{}, *pkg.AppError)

	// Updates the exiting post's concrete fields at posts collection.
	Update(r *http.Request) (interface{}, *pkg.AppError)
}

// A function that implements the functions to endpoints of [PostsRepository].
func SetupPostsEndpoints(router *mux.Router, repo PostsRepository) {
	router.HandleFunc("/posts", func(w http.ResponseWriter, r *http.Request) {
		endpoints.EndpointFuncWrapper(w, r, repo.Fetch)
	}).Methods("GET")

	router.HandleFunc("/posts/{id}", func(w http.ResponseWriter, r *http.Request) {
		endpoints.EndpointFuncWrapper(w, r, repo.Get)
	}).Methods("GET")

	router.HandleFunc("/posts", func(w http.ResponseWriter, r *http.Request) {
		endpoints.EndpointFuncWrapper(w, r, repo.Add)
	}).Methods("POST")

	router.HandleFunc("/posts/{id}", func(w http.ResponseWriter, r *http.Request) {
		endpoints.EndpointFuncWrapper(w, r, repo.Delete)
	}).Methods("DELETE")

	router.HandleFunc("/posts/{id}/{field}", func(w http.ResponseWriter, r *http.Request) {
		endpoints.EndpointFuncWrapper(w, r, repo.Update)
	}).Methods("PUT")
}
