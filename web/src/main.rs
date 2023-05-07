//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

pub mod app;
use app::App;

// Use `wee_alloc` as the global allocator.
#[global_allocator]
static ALLOC: wee_alloc::WeeAlloc = wee_alloc::WeeAlloc::INIT;

fn main() {
    yew::start_app::<App>();
}
