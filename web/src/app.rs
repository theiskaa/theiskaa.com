//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

use stylist::{yew::styled_component, Style};
use yew::prelude::*;

const STYLECSS: &str = include_str!("styles/main.css");

#[styled_component(App)]
pub fn app() -> Html {
    let global_style = match Style::new(STYLECSS) {
        Err(e) => return html! { format!("Something went wrong: {}", e) },
        Ok(s) => s,
    };

    html! {
     <div class={global_style}>
       <div class="overlay">
        <div class="center-div">
          <span class="centered-text">
            <a href="https://github.com/theiskaa/theiskaa/blob/main/me.md">{"me"}</a>
            { " . " }
            <a href="https://instagram.com/theiskaa">{"photos"}</a>
            { " . " }
            <a href="https://twitter.com/theiskaa">{"tweets"}</a>
            { " . " }
            <a href="https://insolite.io">{"insolite"}</a>
          </span>
        </div>
       </div>
      </div>
    }
}
