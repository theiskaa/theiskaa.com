//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

use stylist::{yew::styled_component, Style};
use yew::prelude::*;

use crate::routes::Info;

const STYLECSS: &str = include_str!("styles/main.css");

#[styled_component(App)]
pub fn app() -> Html {
    let global_style = match Style::new(STYLECSS) {
        // Implement pretty error component.
        Err(e) => return html! { format!("Something went wrong: {}", e) },
        Ok(s) => s,
    };

    // TODO: add pretty router.
    html! {
      <div class={global_style}>
        <Info/>
      </div>
    }
}
