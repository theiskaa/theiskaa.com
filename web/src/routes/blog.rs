//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

use crate::components::{ErrorCard, HtmlRender, Loading, RainbowDivider};
use crate::models::{Error, PostModel};
use crate::services::BlogService;
use crate::utils::ToHtml;

use yew::prelude::*;
use yew::virtual_dom::{VList, VNode};
use yew_router::prelude::*;

use super::Route;

#[function_component(BlogList)]
pub fn blog_list() -> Html {
    let blog_state: UseStateHandle<Option<Vec<PostModel>>> = use_state(|| None);
    let error_state: UseStateHandle<Option<Error>> = use_state(|| None);

    {
        let blog_state = blog_state.clone();
        let error_state = error_state.clone();

        use_effect_with_deps(
            move |_| {
                wasm_bindgen_futures::spawn_local(async move {
                    let blog_data = BlogService::fetch().await;
                    match blog_data {
                        Ok(v) => blog_state.set(Some(v)),
                        Err(e) => error_state.set(Some(e)),
                    };
                });
                || ()
            },
            (),
        );
    }

    let blog_widget_impl = match blog_state.as_ref() {
        None => match error_state.as_ref() {
            Some(e) => html! { <ErrorCard model={e.clone()}/> },
            None => html! { <Loading/> },
        },
        Some(v) => {
            let blogs = v.clone().to_html().clone();

            let mut index = 0;
            let mut re_rendered: Vec<VNode> = Vec::new();
            for post in blogs.clone().iter() {
                let id = v.clone().iter().nth(index).unwrap().clone().id.clone();

                re_rendered.push(html! { <Link<Route> to={Route::BlogPage { id }}> { post.clone() } </Link<Route>> });
                if index != blogs.len() - 1 {
                    re_rendered.push(html! { <RainbowDivider/> })
                }

                index += 1;
            }

            let collected_vlist = VList::with_children(
                vec![
                    html! { <h1> { "All Posts" } </h1> },
                    html! { <br/> },
                    html! { <div> { re_rendered.clone() } </div> },
                ],
                None,
            );

            html! { collected_vlist.clone() }
        }
    };

    html! { <div class="main"> { blog_widget_impl.clone() } </div> }
}

#[derive(Clone, Properties, PartialEq)]
pub struct BlogPageProps {
    pub id: String,
}

#[function_component(BlogPage)]
pub fn blog_page(BlogPageProps { id }: &BlogPageProps) -> Html {
    let blog_state: UseStateHandle<Option<PostModel>> = use_state(|| None);
    let error_state: UseStateHandle<Option<Error>> = use_state(|| None);

    {
        let id = id.clone();
        let blog_state = blog_state.clone();
        let error_state = error_state.clone();

        use_effect_with_deps(
            move |_| {
                wasm_bindgen_futures::spawn_local(async move {
                    let blog_data = BlogService::get(id).await;
                    match blog_data {
                        Ok(v) => blog_state.set(Some(v)),
                        Err(e) => error_state.set(Some(e)),
                    };
                });
                || ()
            },
            (),
        );
    }

    let blog_widget_impl = match blog_state.as_ref() {
        None => match error_state.as_ref() {
            Some(e) => html! { <ErrorCard model={e.clone()}/> },
            None => html! { <Loading/> },
        },
        Some(v) => {
            let children: Vec<VNode> = vec![
                html! { <h1> { v.clone().title.clone() } </h1> },
                html! { <p class="meta"> { v.clone().date.clone() } </p> },
                html! { <RainbowDivider/> },
                html! { <HtmlRender id={String::from("")} html={ v.clone().content.clone() }/>},
            ];

            let collected_vlist = VList::with_children(children, None);
            html! { collected_vlist.clone() }
        }
    };

    html! { <div class="main"> { blog_widget_impl.clone() } </div> }
}
