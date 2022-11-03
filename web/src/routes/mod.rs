//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

mod info;

pub use info::*;

use yew::prelude::*;
use yew_router::prelude::*;

#[derive(Routable, Debug, Clone, PartialEq)]
pub enum AppRoute {
    #[at("/")]
    Home,

    #[not_found]
    #[at("/404")]
    NotFound,
}

// Route switcher of application.
// Replaces the [current] route with given [AppRoute]
// appropriate page.
pub fn switch(route: &AppRoute) -> Html {
    match route {
        //
        // TODO: add wrapper for routes. which would be general page that'd have nav-bar
        //
        AppRoute::Home => html! {<Info />},
        AppRoute::NotFound => html! { "Page not found" },
    }
}
