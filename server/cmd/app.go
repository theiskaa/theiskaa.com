//
// This source code is distributed under the terms of Bad Code License.
// You are forbidden from distributing software containing this code to
// end users, because it is bad.
//

package cmd

import (
	"context"

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
	infoRepo := infoService.NewInfoFirebaseService(Firestore)
	info.SetupInfoEndpoints(router, infoRepo)

	// Initialize [posts] endpoints.
	postsRepo := postsService.NewPostsFirebaseService(Firestore)
	posts.SetupPostsEndpoints(router, postsRepo)
}

// InitFirebaseServices setups firebase, firebase
// authentication client, and fire-store database client.
func InitFirebaseServices() {
	ctx := context.Background()

	// This file isn't included in the source code.
	// Just go and create new firebase project. Then download the
	// Service Key Credentials file. And put somewhere under server/ folder.
	// BTW, do not forget putting the project id.
	pathOfKeyFile := "././servicekey.json"

	opts := option.WithCredentialsFile(pathOfKeyFile)
	config := &firebase.Config{ProjectID: "theiskaacom"}
	app, err := firebase.NewApp(ctx, config, opts)

	if err != nil {
		pkg.AlertError(nil, pkg.SomethingWentWrong)
		return
	}
	FireApp = app

	authClient, err := FireApp.Auth(ctx)
	if err != nil {
		pkg.AlertError(nil, pkg.FirebaseAuthSetupError)
		return
	}

	db, err := FireApp.Firestore(ctx)
	if err != nil {
		pkg.AlertError(nil, pkg.FirebaseDBSetupError)
		return
	}

	FireAuth = authClient
	Firestore = db
}
