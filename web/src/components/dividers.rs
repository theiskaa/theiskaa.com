//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

use yew::prelude::*;

#[function_component(RainbowDivider)]
pub fn rainbow_divider() -> Html {
    html! {
        <div>
          <br/>
            <hr class="rainbow"/>
          <br/>
        </div>
    }
}
