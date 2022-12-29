//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

use crate::components::HtmlRender;
use crate::components::{ErrorCard, Loading};
use crate::models::{Error, InfoModel};
use crate::services::InfoService;

use yew::prelude::*;

#[function_component(Info)]
pub fn info() -> Html {
    let info_state: UseStateHandle<Option<InfoModel>> = use_state(|| None);
    let error_state: UseStateHandle<Option<Error>> = use_state(|| None);

    {
        let info_state = info_state.clone();
        let error_state = error_state.clone();

        use_effect_with_deps(
            move |_| {
                wasm_bindgen_futures::spawn_local(async move {
                    let info_data = InfoService::get().await;
                    match info_data {
                        Ok(v) => info_state.set(Some(v)),
                        Err(e) => error_state.set(Some(e)),
                    };
                });
                || ()
            },
            (),
        );
    }

    let info_widget_impl = match info_state.as_ref() {
        Some(v) => html! {  <HtmlRender id={String::from("main")} html={ v.clone().data.clone() }/> },
        None => match error_state.as_ref() {
            Some(e) => html! { <ErrorCard model={e.clone()}/> },
            None => html! { <Loading/> },
        },
    };

    html! { info_widget_impl }
}
