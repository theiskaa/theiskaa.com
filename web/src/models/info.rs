//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

use crate::utils::to_html::ToHtml;
use serde::{Deserialize, Serialize};
use yew::{prelude::*, virtual_dom::VNode};

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
    //  - p -> <p>{}</p>
    pub style: String,

    // The sub links of current link.
    pub children: Vec<Link>,
}

impl ToHtml for Link {
    // Generates a valid [Link] to -> [Html] representation.
    // Merges [title] and [url] with + [style]
    fn to_html(&self) -> Vec<VNode> {
        let children: Vec<VNode> = self.children.clone().to_html();

        let current = {
            if self.url.is_empty() {
                if self.title.clone().as_str() == "\n" {
                    html! { <br/> }
                } else {
                    html! { self.title.clone() }
                }
            } else {
                html! {
                    <a href={ self.url.clone() }> { self.title.clone() } </a>
                }
            }
        };

        let current_render = match self.style.clone().as_str() {
            "bold" => html! {<b>{ current.clone() }</b>},
            "italic" => html! {<i>{ current.clone() }</i>},
            "strong" => html! {<strong>{ current.clone() }</strong>},
            "p" => html! { <p> { current.clone() } </p> },
            _ => current.clone(),
        };

        if children.is_empty() {
            return vec![current_render.clone()];
        }

        return vec![html! {
             <div>
               { current_render.clone() }
               { children.clone() }
             </div>
        }];
    }
}

impl ToHtml for Vec<Link> {
    // Generates a valid [Vec<Link>] to -> [Vec<VNode>] representation.
    // By converting each inner [Link] element.
    fn to_html(&self) -> Vec<VNode> {
        let mut collection: Vec<VNode> = Vec::new();
        for l in self.iter() {
            collection.push(l.clone().to_html().iter().nth(0).unwrap().clone());
        }

        return collection;
    }
}
