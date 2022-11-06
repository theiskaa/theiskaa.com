//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

use crate::components::{ErrorCard, Loading};
use crate::models::{Error, PostModel};
use crate::services::BlogService;
use crate::utils::ToHtml;

use yew::prelude::*;

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
        Some(v) => html! { <div> { v.clone().to_html().clone() } </div> },
        None => match error_state.as_ref() {
            Some(e) => html! { <ErrorCard model={e.clone()}/> },
            None => html! { <Loading/> },
        },
    };

    html! { blog_widget_impl }
}

// TODO: add BlogPage component.
