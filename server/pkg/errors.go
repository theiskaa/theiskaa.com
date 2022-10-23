//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

package pkg

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"firebase.google.com/go/auth"
	"firebase.google.com/go/v4/errorutils"
)

// AppError is a main error model of application.
type AppError struct {
	Message    string `json:"message"`
	StatusCode int    `json:"status_code"`
	Code       string `json:"code"`
}

// AlertError manipulates given errors and writes them as response body.
func AlertError(w *http.ResponseWriter, appErr AppError) {
	if w == nil {
		log.Fatal(appErr)
		return
	}

	writer := *w

	if appErr.StatusCode != 0 {
		writer.WriteHeader(appErr.StatusCode)
	}

	r, _ := json.Marshal(appErr)
	writer.Write(r)

	fmt.Println(appErr)
}

// FromFirebaseError converts firebase-based error structure to AppError.
func FromFirebaseError(err error) AppError {
	switch true {
	case errorutils.IsNotFound(err):
		return NotFound
	case errorutils.IsUnavailable(err):
		return AppUnvailable
	case errorutils.IsUnauthenticated(err):
		return Unauthorized
	case errorutils.IsPermissionDenied(err):
		return SomethingWentWrong
	case errorutils.IsAlreadyExists(err):
	case auth.IsEmailAlreadyExists(err):
		return DataAlreadyExists
	case errorutils.IsInvalidArgument(err), errorutils.IsOutOfRange(err):
		return InvalidFields
	case auth.IsInvalidEmail(err):
		return InvalidEmail
	}

	return AppError{
		Message:    err.Error(),
		StatusCode: 500,
		Code:       "something-went-wrong",
	}
}

// A collection of early defined standard errors.
var (
	NotFound = AppError{
		Message:    "Not found what you are looking for",
		StatusCode: 404,
		Code:       "not-found",
	}

	AppUnvailable = AppError{
		Message:    "Application is unavailable now",
		StatusCode: 500,
		Code:       "unavailable",
	}

	SomethingWentWrong = AppError{
		Message:    "Something went wrong",
		StatusCode: 500,
		Code:       "something-went-wrong",
	}

	FirebaseSetupError = AppError{
		Message:    "Cannot setup firebase application",
		StatusCode: 500,
		Code:       "fire-app-setup",
	}

	FirebaseDBSetupError = AppError{
		Message:    "Cannot setup firebase (firestore) database",
		StatusCode: 500,
		Code:       "fire-db-setup",
	}

	FirebaseAuthSetupError = AppError{
		Message:    "Cannot setup firebase authentication client",
		StatusCode: 500,
		Code:       "fire-auth-setup",
	}

	Unauthorized = AppError{
		Message:    "Request comes from unauthorized user/client",
		StatusCode: 401,
		Code:       "unauthorized",
	}

	InvalidFields = AppError{
		Message:    "Provided fields are invalid",
		StatusCode: 406,
		Code:       "invalid-fields",
	}

	DataAlreadyExists = AppError{
		Message:    "Data already exists",
		StatusCode: 409,
		Code:       "already-exists",
	}

	InvalidRequestBody = AppError{
		Message:    "Invalid request body",
		StatusCode: 409,
		Code:       "invalid-request",
	}

	InvalidEmail = AppError{
		Message:    "Provided email is invalid",
		StatusCode: 403,
		Code:       "invalid-email",
	}

	FieldNotExists = AppError{
		Message:    "Provided field doesn't exists at document",
		StatusCode: 404,
		Code:       "field-not-exists",
	}
)
