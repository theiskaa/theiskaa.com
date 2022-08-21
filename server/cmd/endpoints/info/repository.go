//
// This source code is distributed under the terms of Bad Code License.
// You are forbidden from distributing software containing this code to
// end users, because it is bad.
//

package info

import (
	"net/http"

	"github.com/gorilla/mux"
	"theiskaa.com/cmd/endpoints"
	"theiskaa.com/pkg"
)

type InfoRepository interface {
	// Gets and writes the actual info model (from collections/info/me)
	Get(r *http.Request) (interface{}, *pkg.AppError)

	// Updates concrete field of the (collections/info/me) document.
	// Warn: It shouldn't called directly by its meaning to the actual document "me".
	Update(r *http.Request) (interface{}, *pkg.AppError)

	// Removes concrete field of the (collections/info/me) document.
	// Warn: It shouldn't called directly by its meaning to the actual document "me".
	Delete(r *http.Request) (interface{}, *pkg.AppError)
}

// A function that implements the functions to endpoints of [InfoRepository].
func SetupInfoEndpoints(router *mux.Router, repo InfoRepository) {
	router.HandleFunc("/info", func(w http.ResponseWriter, r *http.Request) {
		endpoints.EndpointFuncWrapper(w, r, repo.Get)
	}).Methods("GET")

	router.HandleFunc("/info/{field}", func(w http.ResponseWriter, r *http.Request) {
		endpoints.EndpointFuncWrapper(w, r, repo.Update)
	}).Methods("PUT")

	router.HandleFunc("/info/{field}", func(w http.ResponseWriter, r *http.Request) {
		endpoints.EndpointFuncWrapper(w, r, repo.Delete)
	}).Methods("DELETE")
}
