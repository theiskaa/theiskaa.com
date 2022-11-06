//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

use yew::{prelude::*, virtual_dom::VNode};

#[derive(Clone, Properties, PartialEq)]
pub struct MenuProps {
    pub route: String,
}

#[function_component(Menu)]
pub fn menu(MenuProps { route }: &MenuProps) -> Html {
    let titles: Vec<(VNode, String)> = vec![
        (html! { <a href="/">{"Info"}</a> }, String::from("/")),
        (
            html! { <a href="/blog">{"Blog"}</a> },
            String::from("/blog"),
        ),
        (
            html! { <a href="/#contact">{"Contact"}</a> },
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

    html! {
      <div class="menu">
        { parsed }
      </div>
    }
}
