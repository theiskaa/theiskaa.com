//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

package info

import (
	"context"
	"io/ioutil"
	"net/http"

	"cloud.google.com/go/firestore"
	"firebase.google.com/go/auth"
	"github.com/gorilla/mux"
	"theiskaa.com/cmd/endpoints/info"
	models "theiskaa.com/cmd/endpoints/info/models"
	"theiskaa.com/pkg"
)

type InfoFirebaseService struct {
	db         *firestore.Client
	auth       *auth.Client
	collection *firestore.CollectionRef
}

// Set [InfoRepository] as [InfoFirebaseService].
var _ info.InfoRepository = &InfoFirebaseService{}

// A generator function to generate the InfoRepository as InfoFirebaseService.
func NewInfoFirebaseService(db *firestore.Client, auth *auth.Client) *InfoFirebaseService {
	return &InfoFirebaseService{db: db, collection: db.Collection("info"), auth: auth}
}

func (info *InfoFirebaseService) Get(r *http.Request) (interface{}, *pkg.AppError) {
	data, err := pkg.GetDocumentsData(*info.collection, "me2")
	if err != nil {
		appErr := pkg.FromFirebaseError(err)
		return nil, &appErr
	}

	return data, nil
}

func (info *InfoFirebaseService) Update(r *http.Request) (interface{}, *pkg.AppError) {
	if _, err := pkg.VerifyFireToken(r.Header.Get("Authorization"), info.auth); err != nil {
		return nil, err
	}

	ctx := context.Background()

	field := mux.Vars(r)["field"]
	if len(field) < 1 {
		return nil, &pkg.InvalidRequestBody
	}

	reqBody, err := ioutil.ReadAll(r.Body)
	if err != nil {
		return nil, &pkg.InvalidRequestBody
	}

	transformedData := models.TransformInfoBody(reqBody)

	opt := firestore.Merge([]string{field})
	if _, writingErr := info.collection.Doc("me2").Set(ctx, transformedData, opt); writingErr != nil {
		appErr := pkg.FromFirebaseError(writingErr)
		return nil, &appErr
	}

	return nil, nil
}
