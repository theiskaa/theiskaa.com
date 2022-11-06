//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

use crate::models::Error;
use yew::prelude::*;

#[derive(Clone, Properties, PartialEq)]
pub struct ErrorCardProps {
    pub model: Error,
}

#[function_component(ErrorCard)]
pub fn error_card(ErrorCardProps { model }: &ErrorCardProps) -> Html {
    html! {
        <div class="error-card">
            <p class="error-title">
              { format!("{}", model).as_str() }
            </p>
        </div>
    }
}
