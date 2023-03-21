//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

package main

import (
	"log"
	"net/http"
	"os"

	"github.com/gorilla/mux"
	"theiskaa.com/cmd"
)

func main() {
	router := mux.NewRouter()
	cmd.SetUp(router)

	port := os.Getenv("PORT")
	if port == "" {
		port = "9090"
		log.Printf("defaulting to port %s", port)
	}

	log.Fatal(http.ListenAndServe(":"+port, router))
}
