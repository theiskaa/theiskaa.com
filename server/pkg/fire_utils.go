//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

package pkg

import (
	"context"
	"strings"

	"cloud.google.com/go/firestore"
	"firebase.google.com/go/auth"
)

// VerifyFireToken  verifies if passed token is valid or not.
// If it is, returns the owner user's user id.
// If not, returns the [Unauthorized] error.
func VerifyFireToken(token string, auth *auth.Client) (*string, *AppError) {
	ctx := context.Background()

	t := strings.ReplaceAll(token, "Bearer ", "")
	res, er := auth.VerifyIDToken(ctx, t)
	if er != nil {
		return nil, &Unauthorized
	}

	return &res.UID, nil
}

// Gets concrete collections' concrete data (as map).
func GetDocumentsData(collection firestore.CollectionRef, id string) (res map[string]interface{}, err error) {
	ctx := context.Background()
	docSnap, err := collection.Doc(id).Get(ctx)

	if err != nil {
		return nil, err
	}

	return docSnap.Data(), nil
}
