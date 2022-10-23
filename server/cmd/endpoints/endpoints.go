//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
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
