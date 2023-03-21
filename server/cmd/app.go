//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

package cmd

import (
	"context"
	"os"

	"cloud.google.com/go/firestore"
	firebase "firebase.google.com/go"
	"firebase.google.com/go/auth"
	"github.com/gorilla/mux"
	"google.golang.org/api/option"
	info "theiskaa.com/cmd/endpoints/info"
	infoService "theiskaa.com/cmd/endpoints/info/services"
	posts "theiskaa.com/cmd/endpoints/posts"
	postsService "theiskaa.com/cmd/endpoints/posts/services"
	"theiskaa.com/pkg"
)

var (
	FireApp   *firebase.App     // The application instance of firebase.
	FireAuth  *auth.Client      // The authentication instance of firebase app.
	Firestore *firestore.Client // The fire-store database client of firebase app.
)

// Setups the essential parts, variables, and endpoints of the application.
func SetUp(router *mux.Router) {
	InitFirebaseServices()

	// Initialize [info] endpoints.
	infoRepo := infoService.NewInfoFirebaseService(Firestore, FireAuth)
	info.SetupInfoEndpoints(router, infoRepo)

	// Initialize [posts] endpoints.
	postsRepo := postsService.NewPostsFirebaseService(Firestore, FireAuth)
	posts.SetupPostsEndpoints(router, postsRepo)
}

// InitFirebaseServices setups firebase, firebase
// authentication client, and fire-store database client.
func InitFirebaseServices() {
	ctx := context.Background()

	firekey := os.Getenv("FIREKEY")
	opts := option.WithCredentialsJSON([]byte(firekey))
	config := &firebase.Config{ProjectID: "theiskaacom"}
	app, err := firebase.NewApp(ctx, config, opts)

	if err != nil {
		pkg.AlertError(nil, pkg.SomethingWentWrong)
		return
	}
	FireApp = app

	authClient, authErr := FireApp.Auth(ctx)
	if authErr != nil {
		pkg.AlertError(nil, pkg.FirebaseAuthSetupError)
		return
	}

	db, dbErr := FireApp.Firestore(ctx)
	if dbErr != nil {
		pkg.AlertError(nil, pkg.FirebaseDBSetupError)
		return
	}

	FireAuth = authClient
	Firestore = db
}
