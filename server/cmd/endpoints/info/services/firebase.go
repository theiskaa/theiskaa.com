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
	"github.com/gorilla/mux"
	"theiskaa.com/cmd/endpoints/info"
	models "theiskaa.com/cmd/endpoints/info/models"
	"theiskaa.com/pkg"
)

type InfoFirebaseService struct {
	db         *firestore.Client
	collection *firestore.CollectionRef
}

// Set [InfoRepository] as [InfoFirebaseService].
var _ info.InfoRepository = &InfoFirebaseService{}

// A generator function to generate the InfoRepository as InfoFirebaseService.
func NewInfoFirebaseService(db *firestore.Client) *InfoFirebaseService {
	return &InfoFirebaseService{db: db, collection: db.Collection("info")}
}

func (info *InfoFirebaseService) Get(r *http.Request) (interface{}, *pkg.AppError) {
	data, err := pkg.GetDocumentsData(*info.collection, "me")
	if err != nil {
		appErr := pkg.FromFirebaseError(err)
		return nil, &appErr
	}

	return data, nil
}

func (info *InfoFirebaseService) Update(r *http.Request) (interface{}, *pkg.AppError) {
	// TODO: implement the authorized user validation.

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
	if _, writingErr := info.collection.Doc("me").Set(ctx, transformedData, opt); writingErr != nil {
		appErr := pkg.FromFirebaseError(writingErr)
		return nil, &appErr
	}

	return nil, nil
}

func (info *InfoFirebaseService) Delete(r *http.Request) (interface{}, *pkg.AppError) {
	// TODO: implement the authorized user validation.

	ctx := context.Background()

	// Get current document data.
	data, err := pkg.GetDocumentsData(*info.collection, "me")
	if err != nil {
		appErr := pkg.FromFirebaseError(err)
		return nil, &appErr
	}

	// Take the field's name, that has to be deleted.
	field := mux.Vars(r)["field"]
	if len(field) < 1 {
		return nil, &pkg.InvalidRequestBody
	}

	// Remove the field from data if it exists.
	if _, ok := data[field]; ok {
		delete(data, field)
	} else {
		return nil, &pkg.FieldNotExists
	}

	// Overwrites the whole document with current modified, data variable.
	// TODO: Instead use, `firestore.Merge([]string{field})` with `firestore.Delete`
	if _, writingErr := info.collection.Doc("me").Set(ctx, data); writingErr != nil {
		appErr := pkg.FromFirebaseError(writingErr)
		return nil, &appErr
	}

	return nil, nil
}
