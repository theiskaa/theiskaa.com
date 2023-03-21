//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

package info

import (
	"net/http"

	"github.com/gorilla/mux"
	"theiskaa.com/cmd/endpoints"
	"theiskaa.com/pkg"
)

type InfoRepository interface {
	// Gets the actual info model (from collections/info/me)
	Get(r *http.Request) (interface{}, *pkg.AppError)

	// Updates concrete field of the (collections/info/me) document.
	// Warn: It shouldn't called directly by its meaning to the actual document "me".
	Update(r *http.Request) (interface{}, *pkg.AppError)
}

// A function that implements the functions to endpoints of [InfoRepository].
func SetupInfoEndpoints(router *mux.Router, repo InfoRepository) {
	router.HandleFunc("/info", func(w http.ResponseWriter, r *http.Request) {
		endpoints.EndpointFuncWrapper(w, r, repo.Get)
	}).Methods("GET")

	router.HandleFunc("/info/{field}", func(w http.ResponseWriter, r *http.Request) {
		endpoints.EndpointFuncWrapper(w, r, repo.Update)
	}).Methods("PUT")
}
