//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

use yew::prelude::*;

#[function_component(Loading)]
pub fn loading() -> Html {
    html! {
      <div class="loading-card">
       <div class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>
      </div>
    }
}
