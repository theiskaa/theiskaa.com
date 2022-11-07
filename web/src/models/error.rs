//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

use serde::{Deserialize, Serialize};
use thiserror::Error as ThisError;

#[derive(ThisError, Clone, Debug, PartialEq)]
pub enum Error {
    #[error("Unauthorized")] // 401
    Unauthorized,

    #[error("Forbidden")] // 403
    Forbidden,

    #[error("Not Found")] // 404
    NotFound,

    #[error("Unprocessable Entity: {0:?}")] // 422
    UnprocessableEntity(AppError),

    #[error("Internal Server Error")] // 500
    InternalServerError,

    #[error("Deserialize Error")] // serde deserialize error
    DeserializeError,

    #[error("Http Request Error")] // request error
    RequestError,
}

// Application formed error model.
#[derive(Serialize, Deserialize, Clone, Debug, PartialEq)]
pub struct AppError {
    pub message: String,
    pub status_code: i32,
    pub code: String,
}
