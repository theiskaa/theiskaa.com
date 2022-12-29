//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

use serde::{Deserialize, Serialize};
use yew::prelude::*;

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, Properties)]
pub struct InfoModel {
    pub picture: String,
    pub data: String,
}
