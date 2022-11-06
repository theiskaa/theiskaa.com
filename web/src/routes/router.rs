//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

use yew::{html::ChildrenRenderer, prelude::*, virtual_dom::VNode};
use yew_router::prelude::*;

use super::{BlogList, BlogPage};
use crate::components::*;
use crate::routes::Info;

#[derive(Clone, Routable, PartialEq)]
pub enum Route {
    #[at("/")]
    Home,

    #[at("/blog")]
    Blog,

    #[at("/blog/:id")]
    BlogPage { id: String },

    #[at("/#contact")]
    Contact,

    #[not_found]
    #[at("/404")]
    NotFound,
}

// Route switcher of application.
// Replaces the [current] route with given [Route]
// appropriate page.
pub fn switch(routes: &Route) -> Html {
    match routes {
        Route::Home => {
            let info: ChildrenRenderer<VNode> = Children::new(vec![html! { <Info/> }]);
            return html! { <Wrapper child={ info.clone() }/> };
        }

        Route::Blog => {
            let blog: ChildrenRenderer<VNode> = Children::new(vec![html! { <BlogList/> }]);
            return html! { <Wrapper child={ blog.clone() }/> };
        }

        Route::BlogPage { id } => {
            let blog_page = Children::new(vec![html! { <BlogPage id={ id.clone() }/> }]);
            return html! { <Wrapper child={ blog_page.clone() }/> };
        }

        Route::Contact => {
            let contact: ChildrenRenderer<VNode> = Children::new(vec![
                // TODO: add contact component.
            ]);
            return html! { <Wrapper child={contact.clone()}/> };
        }

        Route::NotFound => {
            let page_not_found: ChildrenRenderer<VNode> = Children::new(vec![
                // TODO: Add page not found component.
                html! {format!("Page not found -> {}", routes.to_path()).as_str()},
            ]);

            return html! { <Wrapper child={page_not_found.clone()}/>};
        }
    }
}
