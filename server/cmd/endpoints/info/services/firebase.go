//
// This source code is distributed under the terms of Bad Code License.
// You are forbidden from distributing software containing this code to
// end users, because it is bad.
//

package info

import (
	"context"
	"encoding/json"
	"io/ioutil"
	"net/http"

	"cloud.google.com/go/firestore"
	"github.com/gorilla/mux"
	"github.com/mitchellh/mapstructure"
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

// A creator function to generate the InfoRepository as InfoFirebaseService.
func NewInfoFirebaseService(db *firestore.Client) *InfoFirebaseService {
	return &InfoFirebaseService{db: db, collection: db.Collection("info")}
}

func (info *InfoFirebaseService) Get(r *http.Request) (interface{}, *pkg.AppError) {
	data, err := pkg.GetDocumentsData(*info.collection, "me")
	if err != nil {
		appErr := pkg.FromFirebaseError(err)
		return nil, &appErr
	}

	infoData := models.Info{}
	mapstructure.Decode(data, &infoData)

	return data, nil
}

func (info *InfoFirebaseService) Update(r *http.Request) (interface{}, *pkg.AppError) {
	ctx := context.Background()

	field := mux.Vars(r)["field"]
	if len(field) < 1 {
		return nil, &pkg.InvalidRequestBody
	}

	reqBody, err := ioutil.ReadAll(r.Body)
	if err != nil {
		return nil, &pkg.InvalidRequestBody
	}

	var infoData map[string]interface{}
	json.Unmarshal(reqBody, &infoData)

	if _, writingErr := info.collection.Doc("me").Set(ctx, infoData, firestore.Merge([]string{field})); writingErr != nil {
		appErr := pkg.FromFirebaseError(err)
		return nil, &appErr
	}

	return nil, nil
}

func (info *InfoFirebaseService) Overwrite(r *http.Request) (interface{}, *pkg.AppError) {
	ctx := context.Background()

	reqBody, err := ioutil.ReadAll(r.Body)
	if err != nil {
		return nil, &pkg.InvalidRequestBody
	}

	var infoData map[string]interface{}
	json.Unmarshal(reqBody, &infoData)

	if _, writingErr := info.collection.Doc("me").Set(ctx, infoData); writingErr != nil {
		appErr := pkg.FromFirebaseError(err)
		return nil, &appErr
	}

	return nil, nil
}
