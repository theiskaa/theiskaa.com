//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

use super::Dio;
use crate::models::*;

pub struct BlogService {}
impl BlogService {
    // Fetches the all post models.
    pub async fn fetch() -> Result<Vec<PostModel>, Error> {
        Dio::get::<Vec<PostModel>>(String::from("/posts")).await
    }

    // Gets concrete post model by its [id].
    pub async fn get(id: String) -> Result<PostModel, Error> {
        Dio::get::<PostModel>(format!("/posts/{}", id)).await
    }
}
