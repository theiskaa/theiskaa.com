//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

use crate::utils::to_html::ToHtml;
use serde::{Deserialize, Serialize};
use yew::{prelude::*, virtual_dom::VNode};

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, Properties)]
pub struct PostModel {
    pub id: String,
    pub title: String,
    pub description: String,
    pub cover: String,
    pub date: String,
    pub content: Vec<Href>,
}

// The content token reference model.
// Which is a dynamic structure that could represent:
// - text(normal/linked)
// - image
// - code-snippet
//
// Each that representation should be handled by [Href]'s [type].
// And [src] of [Href] is the main source of value.
#[derive(Serialize, Deserialize, Clone, Debug, PartialEq)]
pub struct Href {
    // typ is a field that represents the rendering style of [Href].
    //
    // Could be:
    //  - text
    //  - image
    //  - code
    pub typ: String,

    // src is a field that used as source of content that has to be rendered.
    pub src: String,

    // Style is a font-style identifier of [src] field.
    // > In case of [type] being any kind of text type.
    //
    // Could be:
    //  - bold
    //  - italic
    //  - strong
    pub style: String,

    // The reference URL provider for [src].
    // > In case of [type] being linked text type. <text>.
    //
    // same approach of `<a href="http://">{Src}</a>`
    // but in rust structure model.
    pub url: String,
}

impl ToHtml for PostModel {
    // Generates a preview view from post model.
    // TODO: add class appropriate styling to styles/main.css
    fn to_html(&self) -> Vec<VNode> {
        let preview = html! {
            <div class="post-preview">
                <img class="post-preview-image" src={ self.clone().cover } alt="post-cover-picture" title="post-cover-picture"/>
                <div class="post-preview-content">
                  <div class="post-preview-id"> { format!("#{}", self.id.clone()).as_str() } </div>
                  <div class="post-preview-title"> { self.title.clone().as_str() } </div>
                  <div class="post-preview-desc"> { self.description.clone().as_str() } </div>
                  <div class="post-preview-date"> { self.date.clone().as_str() } </div>
                </div>
            </div>
        };

        return vec![preview];
    }
}

impl ToHtml for Vec<PostModel> {
    //  Generates a valid vector of [VNode] from vector of [PostModel]
    fn to_html(&self) -> Vec<VNode> {
        let mut posts: Vec<VNode> = Vec::new();
        for p in self.clone().iter() {
            posts.push(p.clone().to_html().iter().nth(0).unwrap().clone());
        }

        return posts;
    }
}

//
// TODO: impl ToHtml for Href {}
// the implementation
//
