//
// This source code is distributed under the terms of Bad Code License.
// You are forbidden from distributing software containing this code to
// end users, because it is bad.
//

package endpoints

import (
	"encoding/json"
	"net/http"

	"theiskaa.com/pkg"
)

// EndpointFuncWrapper wraps endpoint functionalities to make easy and readable error catchings.
func EndpointFuncWrapper(w http.ResponseWriter, r *http.Request, action func(r *http.Request) (interface{}, *pkg.AppError)) {
	w.Header().Set("Content-Type", "application/json")

	res, err := action(r)
	if err != nil {
		pkg.AlertError(&w, *err)
		return
	}

	if res != nil {
		json.NewEncoder(w).Encode(res)
	}
}
