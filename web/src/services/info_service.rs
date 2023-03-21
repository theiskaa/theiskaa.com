//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

use super::Dio;
use crate::models::*;

pub struct InfoService {}
impl InfoService {
    // Gets the info data
    pub async fn get() -> Result<InfoModel, Error> {
        Dio::get::<InfoModel>(String::from("/info")).await
    }
}
