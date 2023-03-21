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
    pub content: String,
}

impl ToHtml for PostModel {
    // Generates a preview view from post model.
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
