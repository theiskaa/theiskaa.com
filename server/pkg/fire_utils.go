package pkg

import (
	"context"

	"cloud.google.com/go/firestore"
)

// Gets concrete collections' concrete data (as map).
func GetDocumentsData(collection firestore.CollectionRef, id string) (res map[string]interface{}, err error) {
	ctx := context.Background()
	docSnap, err := collection.Doc(id).Get(ctx)

	if err != nil {
		return nil, err
	}

	return docSnap.Data(), nil
}
