//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

use crate::{components::menu::Menu, routes::Route};
use yew::prelude::*;
use yew_router::{hooks, Routable};

#[derive(Clone, Properties, PartialEq)]
pub struct WrapperProps {
    pub child: Children,
}

#[function_component(Wrapper)]
pub fn wrapper(WrapperProps { child }: &WrapperProps) -> Html {
    let route: Route = hooks::use_route().unwrap_or_default();

    // The [Menu] component implementation.
    let menu = html! { <Menu route={route.clone().to_path() }/> };

    // The sidebar with [menu] merged.
    let sidebar = html! {
      <div class="sidebar">
       <header>{"Ismael Sh"}</header>
       { menu.clone() }
      </div>
    };

    html! {
      <div>
       <div class="wrapper">
         <div class="columns">
          { sidebar.clone() }
          { child.clone() } // The < main > class.
         </div>
         <Footer/>
       </div>
      </div>
    }
}

#[function_component(Footer)]
pub fn footer() -> Html {
    html! {
      <footer class="footer">
        <p> { "Copyright © 2022 Ismael Shakverdiev" } </p>
       </footer>
    }
}
