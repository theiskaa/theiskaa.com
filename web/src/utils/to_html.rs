//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

use yew::virtual_dom::VNode;

//
// The html utility trait to bring [to_html] converter method
// to each kind of structure implementation.
//
pub trait ToHtml {
    // Converts pointed element to [VNode] vector.
    fn to_html(&self) -> Vec<VNode>;
}
