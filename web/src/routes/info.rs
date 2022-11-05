//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

use crate::models::{Error, InfoModel};
use crate::services::InfoService;
use crate::utils::ToHtml;

use yew::prelude::*;
use yew::virtual_dom::VNode;

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
        Some(v) => html! {
            <InfoWidget info={v.clone()}/>
        },
        None => match error_state.as_ref() {
            Some(e) => {
                // TODO: add pretty error component.
                html! {format!("Error getting info: {}", e).as_str()}
            }
            None => {
                // TODO: add pretty loading component.
                html! {". . . LOADING . . ."}
            }
        },
    };

    html! {
        info_widget_impl
    }
}

#[derive(Properties, PartialEq)]
pub struct InfoWidgetProps {
    pub info: InfoModel,
}

#[function_component(InfoWidget)]
fn info_widget(InfoWidgetProps { info }: &InfoWidgetProps) -> Html {
    let collections: Vec<VNode> = vec![
        html! { <img class="avatar" src={ info.clone().picture } alt="My picture" title="profile picture"/> },
        html! { <p style="margin-top: 0; line-height: 1.2em;"> { info.clone().greeting.to_html() } </p> },
        html! { <p> { info.clone().career.to_html() } </p> },
        html! { <div class="clearfix"></div> },
        html! { <h2 id="contact">{"Contact"}</h2> },
        html! { <div class="contact"> { info.clone().contact.to_html() } </div> },
    ];

    html! { <div class="main"> { collections } </div> }
}
