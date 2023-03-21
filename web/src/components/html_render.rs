//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

use web_sys::Node;
use yew::{prelude::*, virtual_dom::VNode};

#[derive(Clone, Properties, PartialEq)]
pub struct HtmlRenderProps {
    pub id: String,
    pub html: String,
}

// A component to parse string html data to actual [VNode]. i.e [Html].
#[function_component(HtmlRender)]
pub fn html_render(HtmlRenderProps { id, html }: &HtmlRenderProps) -> Html {
    let pdoc = web_sys::window().unwrap().document();
    let pelement = pdoc.unwrap().create_element("div").unwrap();

    pelement.set_class_name(id);
    pelement.set_inner_html(&html[..]);

    VNode::VRef(Node::from(pelement))
}
