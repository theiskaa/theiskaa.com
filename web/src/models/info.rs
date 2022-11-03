//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

use serde::{Deserialize, Serialize};
use yew::Properties;

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, Properties)]
pub struct InfoModel {
    pub picture: String,
    pub greeting: Vec<Link>,
    pub career: Vec<Link>,
    pub contact: Vec<Link>,
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq)]
pub struct Link {
    // Title is the main domain of [Link] structure.
    pub title: String,

    // The reference URL provider for [title].
    // same approach of `<a href="http://">{Title}</a>`
    // but in go structure model.
    pub url: String,

    // Style is a font-style identifier of [Title] field.
    // Could be:
    //  - bold
    //  - italic
    //  - strong
    pub style: String,
}

impl InfoModel {
    pub fn to_string(&self) -> String {
        format!(
            "
            picture: {},
            greeting: {},
            career: {},
            contact: {},
        ",
            self.clone().picture,
            self.clone().greeting.len(),
            self.clone().career.len(),
            self.clone().contact.len(),
        )
    }
}
