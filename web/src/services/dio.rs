//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

use crate::models::*;
use dotenv_codegen::dotenv;
use reqwest::header::{ACCEPT, ACCESS_CONTROL_ALLOW_ORIGIN, CONTENT_TYPE};
use serde::{de::DeserializeOwned, Serialize};

// Get API root from env.
const API_ROOT: &str = dotenv!("API_ROOT");

// Dio is the main structure of http interaction functions.
//
// Inspired from flutter-china community's dio http library.
pub struct Dio {}

impl Dio {
    // Custom [request] implementation based on [DELETE] method.
    pub async fn delete<T>(url: String) -> Result<T, Error>
    where
        T: DeserializeOwned + 'static + std::fmt::Debug,
    {
        Dio::request(reqwest::Method::DELETE, url, ()).await
    }

    // Custom [request] implementation based on [GET] method.
    pub async fn get<T>(url: String) -> Result<T, Error>
    where
        T: DeserializeOwned + 'static + std::fmt::Debug,
    {
        Dio::request(reqwest::Method::GET, url, ()).await
    }

    // Custom [request] implementation based on [POST] method.
    pub async fn post<B, T>(url: String, body: B) -> Result<T, Error>
    where
        T: DeserializeOwned + 'static + std::fmt::Debug,
        B: Serialize + std::fmt::Debug,
    {
        Dio::request(reqwest::Method::POST, url, body).await
    }

    // Custom [request] implementation based on [PUT] method.
    pub async fn put<B, T>(url: String, body: B) -> Result<T, Error>
    where
        T: DeserializeOwned + 'static + std::fmt::Debug,
        B: Serialize + std::fmt::Debug,
    {
        Dio::request(reqwest::Method::PUT, url, body).await
    }

    // Main request caller and result parser of app.
    // Uses [API_ROOT] as main root of request API, and adds [url] to build up the
    // full path url to call a request on.
    pub async fn request<B, T>(method: reqwest::Method, url: String, body: B) -> Result<T, Error>
    where
        T: DeserializeOwned + 'static + std::fmt::Debug,
        B: Serialize + std::fmt::Debug,
    {
        let allow_body = method == reqwest::Method::POST || method == reqwest::Method::PUT;
        let url = format!("{}{}", API_ROOT, url);

        let mut builder = reqwest::Client::new()
            .request(method, url.clone())
            .header(CONTENT_TYPE, "application/json")
            .header(ACCEPT, "application/json")
            .header(ACCESS_CONTROL_ALLOW_ORIGIN, "*");

        if allow_body {
            builder = builder.json(&body);
        }

        let response = builder.send().await;

        if let Ok(data) = response {
            if data.status().is_success() {
                let data: Result<T, _> = data.json::<T>().await;
                if let Ok(data) = data {
                    log::debug!("Response: {:?}", data);
                    return Ok(data);
                } else {
                    return Err(Error::DeserializeError);
                }
            }

            match data.status().as_u16() {
                401 => Err(Error::Unauthorized),
                403 => Err(Error::Forbidden),
                404 => Err(Error::NotFound),
                500 => Err(Error::InternalServerError),
                422 => {
                    let data: Result<AppError, _> = data.json::<AppError>().await;
                    if let Ok(data) = data {
                        Err(Error::UnprocessableEntity(data))
                    } else {
                        Err(Error::DeserializeError)
                    }
                }
                _ => Err(Error::RequestError),
            }
        } else {
            Err(Error::RequestError)
        }
    }
}
