//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

package main

import (
	"log"
	"net/http"

	"github.com/gorilla/mux"
	"theiskaa.com/cmd"
)

// FIXME: runs on local server at :8080
// TODO:  run at remote server.
func main() {
	router := mux.NewRouter()
	cmd.SetUp(router)

	log.Fatal(http.ListenAndServe(":8080", router))
}
