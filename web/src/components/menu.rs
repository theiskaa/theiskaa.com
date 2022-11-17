//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

use yew::{prelude::*, virtual_dom::VNode};
use yew_router::prelude::*;

use crate::routes::Route;

#[derive(Clone, Properties, PartialEq)]
pub struct MenuProps {
    pub route: String,
}

#[function_component(Menu)]
pub fn menu(MenuProps { route }: &MenuProps) -> Html {
    let titles: Vec<(VNode, String)> = vec![
        (
            html! { <Link<Route> to={Route::Home}> { "About" } </Link<Route>> },
            String::from("/"),
        ),
        (
            html! { <Link<Route> to={Route::Blog}> { "Blog" } </Link<Route>> },
            String::from("/blog"),
        ),
        // TODO: impl local posts page.
        (
            html! { <a href="https://github.com/theiskaa">{"Projects"}</a> },
            String::from(""),
        ),
        (
            html! { <Link<Route> to={Route::Contact}> { "Contact" } </Link<Route>> },
            String::from("/Contact"),
        ),
    ];

    let mut parsed: Vec<VNode> = vec![];
    for title in titles.iter() {
        let class_name = {
            if title.1.clone() == route.clone() {
                "menu-item active"
            } else {
                "menu-item"
            }
        };

        parsed.push(html! { <div class={ class_name.clone() }> { title.0.clone() } </div> });
    }

    html! { <div class="menu"> { parsed } </div> }
}
